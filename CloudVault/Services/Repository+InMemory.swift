//
//  InMemory.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 08.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
class InMemoryRepository: Repository {
    
    private var folders: [URL]
    private var files: Dictionary<URL, Data>
    private var wrappers: Dictionary<URL, FileWrapper>
    
    public init(folders: [URL] = [], files:Dictionary<URL, Data> = [:], wrappers:Dictionary<URL, FileWrapper> = [:]) {

        self.folders = folders.map{ $0.lastPathComponent == "/" ? $0 : $0.appendingPathComponent("/") }
        self.files = files
        self.wrappers = wrappers
        
        super.init()
        
    }
    
    override public func fileExists(name filename: URL) -> RepositoryExistsOutput {
        
        let fileExist = files[filename] != nil
        return .success(fileExist)

    }

    override public func folderExists(name foldername: URL) -> RepositoryExistsOutput {

        let folderExist = folders.contains(foldername)
        return .success(folderExist)
        
    }
    
    override public func createFolder(name foldername: URL) -> RepositoryExistsOutput {
        
        return self.folderExists(name: foldername).flatMap { itExists  in
            
            guard !itExists else {
                return .failure(.folderAlreadyExist(foldername.absoluteString))
            }
            
            self.folders.append(foldername)
            return .success(true)
            
        }
        
    }
    
    override public func listFolder(foldername: URL, recursive: Bool = false) -> ReposityListOutput {

        return self.folderExists(name: foldername).flatMap { itExists  in
            
            guard !itExists else {
                return .failure(.folderAlreadyExist(foldername.absoluteString))
            }
            
            let folder = foldername.absoluteString
            let filenames = self.files.keys
                .filter { $0.absoluteString.hasPrefix(folder)}
                .map { RepositoryFile(url: $0) }
            
            return .success(filenames)
            
        }
            
    }
    
    override public func loadFile(filename: URL) -> ReposityFileOutput {
        
        return self.fileExists(name: filename).flatMap { itExists  in
            
            guard itExists else {
                return .failure(.fileDoNotExist(filename.absoluteString))
            }
            
            let filedata = self.files[filename]
            let filedescriptor = RepositoryFile(url: filename, data: filedata)
            return .success(filedescriptor)
            
        }
    
    }
    
    override public func saveFileWrapper(filename: URL, fileWrapper: FileWrapper) -> RepositoryOperationOutput {
        self.wrappers[filename] = fileWrapper
        return .success(true)
    }
    
    override public func createFile(filename: URL, data: Data) -> RepositoryOperationOutput {
    
        let foldername = filename.deletingLastPathComponent()
        return self.folderExists(name: foldername).flatMap { folderExists in
            
            guard folderExists else {
                return .failure(.folderDoNotExist(foldername.absoluteString))
            }
            
            self.files[filename] = data
            return .success(true)
            
        }
    
    }
    
    override public func appendToFile(filename: URL, data: Data) -> RepositoryOperationOutput {
    
        guard let persisteddata = self.files[filename] else {
            
            self.files[filename] = data
            return .success(true)
            
        }
        
        guard let persistedValue = String(data: persisteddata, encoding: .utf8) else {
            return .failure(.unableToAccessDisk)
        }
        
        guard let parsedData = String(data: data, encoding: .utf8) else {
            return .failure(.undefined)
        }
        
        let updated = persistedValue.appending(parsedData)
        self.files[filename] = updated.data(using: .utf8)
        return .success(true)
    
    }
    
    override public func removeFile(filename: URL) -> RepositoryOperationOutput {

        return self.fileExists(name: filename).flatMap { itExists  in
            
            guard itExists else {
                return .failure(.fileDoNotExist(filename.absoluteString))
            }
            
            self.files.removeValue(forKey: filename)
            return .success(true)
            
        }
        
    }
    
    public func getData(for filename: URL) -> Data? { return self.files[filename] }
    
}
