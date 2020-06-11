//
//  Repository.swift
//  CloudVaultTests
//
//  Created by Gustavo Tavares on 08.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import XCTest
@testable import CloudVault

class Repository: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRepositoryFindInexistentFolder() throws {
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("inexistent")
        let sut = InMemoryRepository(folders: [])
        
        XCTAssertFalse(try sut.folderExists(name: foldername).get())
        
    }
    
    func testRepositoryFindExistentFolder() throws {
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("inexistent")
        let sut = InMemoryRepository(folders: [foldername])
        
        XCTAssertTrue(try sut.folderExists(name: foldername.appendingPathComponent("/")).get())
        
    }
    
    func testRepositoryFindInexistentFile() throws {
        
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = folder.appendingPathComponent("inexistent.txt")
        let sut = InMemoryRepository(folders: [folder])
        
        XCTAssertFalse(try sut.fileExists(name: filename).get())
        
    }
    
    func testRepositoryFindExistentFile() throws {
        
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = folder.appendingPathComponent("testfile.txt")
        let filedata = "This is a test".data(using: .utf8)!
        let mockData = [filename: filedata]
        let sut = InMemoryRepository(folders: [folder], files: mockData)
        
        XCTAssertTrue(try sut.fileExists(name: filename).get())
        
    }

    func testRepositoryCreateInexistentFolder() throws {
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("inexistent")
        let sut = InMemoryRepository(folders: [])
        
        let result = sut.createFolder(name: foldername)
        XCTAssertTrue(try result.get())
        
    }
    
    func testRepositoryCreateAlreadyExistentFolder() throws {
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("existent")
        let sut = InMemoryRepository(folders: [foldername])
        
        let result = sut.createFolder(name: foldername.appendingPathComponent("/"))
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, FileRepositoryError.folderAlreadyExist(foldername.appendingPathComponent("/").absoluteString))
        default: XCTFail("FolderAlreadyExistent Error expected")
        }
        
    }
  
    func testLoadExistentFile() throws {
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("existent")
        let filename = foldername.appendingPathComponent("newfile.txt")
        let filedata = "Mock Data for Tests".data(using: .utf8)!
        
        let sut = InMemoryRepository(folders: [foldername], files: [filename: filedata])
        let result = sut.loadFile(filename: filename)
        let descriptor = try result.get()
        let data = descriptor.data
        XCTAssertEqual(filedata, data)

    }
    
    func testLoadInexistentFile() throws {
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("existent")
        let filename = foldername.appendingPathComponent("inexistent.txt")
        
        let sut = InMemoryRepository(folders: [foldername])
        let result = sut.loadFile(filename: filename)
        switch result {
        case .failure(let error):
            
            switch error {
            case .fileDoNotExist(_): break
            default: XCTFail("FileDoNotExistent Error expected")
            }
            
        default: XCTFail("FileDoNotExistent Error expected")
        }

    }
    
    func testCreateFileInExistentFolder() throws {
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("existent")
        let filename = foldername.appendingPathComponent("newfile.txt")
        let filedata = "Mock Data for Tests".data(using: .utf8)!
        
        let sut = InMemoryRepository(folders: [foldername])
        let result = sut.createFile(filename: filename, data: filedata)
        XCTAssertTrue(try result.get())

    }
    
    func testCreateFileInInexistentFolder() throws {
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("existent")
        let filename = foldername.appendingPathComponent("newfile.txt")
        let filedata = "Mock Data for Tests".data(using: .utf8)!
        
        let sut = InMemoryRepository(folders: [])
        let result = sut.createFile(filename: filename, data: filedata)
        switch result {
        case .failure(let error):
            
            switch error {
            case .folderDoNotExist(_): break
            default: XCTFail("FolderDoNotExistent Error expected")
            }
            
        default: XCTFail("FolderDoNotExistent Error expected")
        }

    }
       
    func testSaveFileWrapper() throws {
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("existent")
        let filename = foldername.appendingPathComponent("newfile.txt")
        let filedata = "Mock Data for Tests".data(using: .utf8)!
        let wrapper = FileWrapper(regularFileWithContents: filedata)
        
        let sut = InMemoryRepository(folders: [foldername])
        let result = sut.saveFileWrapper(filename: filename, fileWrapper: wrapper)
        XCTAssertTrue(try result.get())

    }
    
    func testAppendToFileInExistentFile() throws {
        
        let firstdata = "Mock Data for Tests"
        let seconddata = "AnotherText"
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("existent")
        let filename = foldername.appendingPathComponent("newfile.txt")
        let filedata = firstdata.data(using: .utf8)!
        
        let sut = InMemoryRepository(folders: [foldername], files: [filename: filedata])
        
        let appended = seconddata.data(using: .utf8)!
        let result = sut.appendToFile(filename: filename, data: appended)
        XCTAssertTrue(try result.get())
        
        guard let persisted = sut.getData(for: filename) else {
            XCTFail("Expected Data Persisted on Repository!")
            return
        }
        
        let parsed = String(data: persisted, encoding: .utf8)
        XCTAssertEqual(firstdata.appending(seconddata), parsed)
        
    }
    
    func testAppendToFileInInexistentFile() throws {
        
        let seconddata = "AnotherText"
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("existent")
        let filename = foldername.appendingPathComponent("anotherfile.txt")
        
        let sut = InMemoryRepository(folders: [foldername])
        
        let appended = seconddata.data(using: .utf8)!
        let result = sut.appendToFile(filename: filename, data: appended)
        XCTAssertTrue(try result.get())
        
        guard let persisted = sut.getData(for: filename) else {
            XCTFail("Expected Data Persisted on Repository!")
            return
        }
        
        let parsed = String(data: persisted, encoding: .utf8)
        XCTAssertEqual(seconddata, parsed)
        
    }
    
    func testRemoveExistentFile() throws {
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("existent")
        let filename = foldername.appendingPathComponent("newfile.txt")
        let filedata = "Mock Data for Tests".data(using: .utf8)!
        
        let sut = InMemoryRepository(folders: [foldername], files: [filename: filedata])
        let result = sut.removeFile(filename: filename)
        XCTAssertTrue(try result.get())

    }
    
    func testRemoveInexistentFile() throws {
        
        let rootFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let foldername = rootFolder.appendingPathComponent("existent")
        let filename = foldername.appendingPathComponent("inexistent.txt")
        
        let sut = InMemoryRepository(folders: [foldername])
        let result = sut.removeFile(filename: filename)
        switch result {
        case .failure(let error):
            
            switch error {
            case .fileDoNotExist(_): break
            default: XCTFail("FileDoNotExistent Error expected")
            }
            
        default: XCTFail("FileDoNotExistent Error expected")
        }

    }
    
}
