//
//  App+FileRepository.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 30.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import Combine

private let INBOX_FOLDER_NAME = "Shared"
private let DATA_FOLDER_NAME = "Data"
private let TEMP_FOLDER_NAME = "Temp"
private let SYS_FOLDER_NAME = "System"
private let PACKAGE_EXTENSION = "pckg"
private let SYS_LOG_INITIALIZATION_CONTENT = "LOG INITIALIZATION"

class AppRepository: ObservableObject {
    
    private static var _shared: AppRepository?
    
    public static var shared:AppRepository {
        
        if AppRepository._shared == nil {
        
            let repo = AppRepository()
            repo.initializeFolders()
            repo.initializeFiles()
            repo.initializePublishers()
            
            AppRepository._shared = repo
        
        }
        
        return AppRepository._shared!
        
    }
    
    // Static Method to accept Packages to be persisted on the Shared Folder
    public static func addToDropBox(package: AssetPackage) -> Bool {

        let appRepo = AppRepository()
        let packageULID = ULID().stringValue
        let root = appRepo.repository.root(for: .appGroup)
        let filepath = root
            .appendingPathComponent(INBOX_FOLDER_NAME)
            .appendingPathComponent(packageULID)
            .appendingPathExtension(PACKAGE_EXTENSION)

        guard let wrapper = package.fileWrapper else {
            return false
        }

        let saveFileResult = appRepo.repository.saveFileWrapper(filename: filepath, fileWrapper: wrapper)
        switch saveFileResult {
        case .success(let result): return result
        default: return false;
        }

    }
    
    private var repository: Repository
    
    @Published var assets: [AssetPackage] = []
    
    private init() {
        self.repository = Repository(appGroupId: AppSystem.appGroupId)
    }
           
    public func getFileListFromSharedFolder() -> ReposityListOutput {
        let localroot = self.repository.root(for: .appGroup)
        let datafolder = localroot.appendingPathComponent(INBOX_FOLDER_NAME)
        return repository.listFolder(foldername: datafolder)
    }
    
    public func getFileListFromLocalFolder(folderName: String) -> ReposityListOutput {
        
        let localroot = self.repository.root(for: .local)
        let datafolder = localroot.appendingPathComponent(folderName)
        return repository.listFolder(foldername: datafolder)

    }
    
    public func clearInboxFolder() -> Bool {
        
        self.getFileListFromSharedFolder()
            .getValidValues()
            .forEach { (file: RepositoryFile) in _ = self.repository.removeFile(filename: file.url) }
        
        return true

    }

    public func clearDataFolder() -> Bool {
        
        self.getFileListFromLocalFolder(folderName: DATA_FOLDER_NAME)
            .getValidValues()
            .forEach { (file: RepositoryFile) in _ = self.repository.removeFile(filename: file.url) }
        
        return true
    }

    public func clearTempFolder() -> Bool {
        
        self.getFileListFromLocalFolder(folderName: TEMP_FOLDER_NAME)
            .getValidValues()
            .forEach { (file: RepositoryFile) in _ = self.repository.removeFile(filename: file.url) }
        
        return true
    }
    
    public func clearSystemFolder() -> Bool {
        
        self.getFileListFromLocalFolder(folderName: SYS_FOLDER_NAME)
            .getValidValues()
            .forEach { (file: RepositoryFile) in _ = self.repository.removeFile(filename: file.url) }
        
        return true
    }
    
    public func saveOnSharedFolder(package: AssetPackage) -> Bool {

        let packageULID = ULID().stringValue
        let root = self.repository.root(for: .appGroup)
        let filepath = root
            .appendingPathComponent(INBOX_FOLDER_NAME)
            .appendingPathComponent(packageULID)
            .appendingPathExtension(PACKAGE_EXTENSION)
        
        guard let wrapper = package.fileWrapper else {
            return false
        }

        let saveFileResult = repository.saveFileWrapper(filename: filepath, fileWrapper: wrapper)
        switch saveFileResult {
        case .success(let result): return result
        default: return false;
        }
        
    }
    
    public func decryptToTemporaryUrl(package: AssetPackage) -> URL? {
        
        let filename = package.asset.name
        let temporaryUrl = self.repository.root(for: .local)
            .appendingPathComponent(TEMP_FOLDER_NAME)
            .appendingPathComponent(filename)
        
        let assetData = package.asset.data
        let saveFileResult = repository.createFile(filename: temporaryUrl, data: assetData)
        switch saveFileResult {
        case .success(let result): return result ? temporaryUrl : nil
        default: return nil
        }
        
    }
    
    public func movePackageToDataFolder(package: AssetPackage) -> Bool {
        
        guard let url = package.url else { return false }
        return self.moveFileToDataFolder(url: url)
        
    }
    
    public func moveFileToDataFolder(url: URL) -> Bool {
        
        let filename = url.lastPathComponent
        let destination = repository.root(for: .local).appendingPathComponent(DATA_FOLDER_NAME).appendingPathComponent(filename)
        let fileMove = repository.moveFile(from: url, to: destination)
        switch fileMove {
        case .success(let result):

            self.reload()
            return result

        case .failure( _): return false
        }
        
    }
          
    public func removePackage(package: AssetPackage) -> Bool {
        
        guard let url = package.url else { return false }
        return self.removeFile(url: url)
        
    }
    
    public func removeFile(url: URL) -> Bool {
        
        let fileRemoval = self.repository.removeFile(filename: url)
        switch fileRemoval {
        case .success(let result):
            self.reload()
            return result
        case .failure(let repositoryError):
            AppSystem.shared.logException(error: repositoryError, file: #file, line: #line - 4)
            return false
        }
        
    }
    
    private func appendLogToFile(message: String, in filename: URL) -> Void {
        self.initializeFiles()
        let linebreaked = (message + "\n").data(using: .utf8)!
        _ = self.repository.appendToFile(filename: filename, data: linebreaked)
    }
    
    private func initializeFolders() -> Void {
               
        let inputFolder = repository.root(for: .appGroup).appendingPathComponent(INBOX_FOLDER_NAME)
        self.createFolderIfNotExistent(folder: inputFolder)

        let dataFolder = repository.root(for: .local).appendingPathComponent(DATA_FOLDER_NAME)
        self.createFolderIfNotExistent(folder: dataFolder)

        let tempFolder = repository.root(for: .local).appendingPathComponent(TEMP_FOLDER_NAME)
        self.createFolderIfNotExistent(folder: tempFolder)
        
        let sysFolder = repository.root(for: .local).appendingPathComponent(SYS_FOLDER_NAME)
        self.createFolderIfNotExistent(folder: sysFolder)
        
    }

    private func createFolderIfNotExistent(folder: URL) -> Void {
        
        let folderExists = repository.folderExists(name: folder)
        
        switch folderExists {
        case .success(let exists):

            if (exists) { break }
            AppSystem.shared.logDiagnose(message: "Folder \(folder.lastPathComponent) does not Exist!")
            _ = repository.createFolder(name: folder)

        case .failure(let repositoryError):
            AppSystem.shared.logException(error: repositoryError, file: #file, line: #line - 3)
            
        }
        
    }

    private func initializeFiles() -> Void {
        
        let initDate = AppSystem.shared.isoFormatter.string(for: Date()) ?? "NoDate"
        let initData = "\(initDate): File Initialization!\n".data(using: .utf8)!
        
        [self.sysLogFileName, self.sysDiagnoseFileName, self.sysErrorFileName].forEach {
            self.createFileIfNotExistent(filename: $0, content: initData)
        }
        
    }
    
    private func initializePublishers() -> Void {
        
        let inbox: [AssetPackage] = self.getFileListFromSharedFolder().map { arrayOfFiles in
            arrayOfFiles.map { file in AssetPackage.from(url: file.url) }
        }.getValidValues()

        let assets: [AssetPackage] = self.getFileListFromLocalFolder(folderName: DATA_FOLDER_NAME).map { arrayOfFiles in
            arrayOfFiles.map { file in AssetPackage.from(url: file.url) }
        }.getValidValues()
        
        print(inbox.count)
        print(assets.count)
        
        self.assets = []
        self.assets.append(contentsOf: inbox)
        self.assets.append(contentsOf: assets)
        
    }
    
    private var sysLogFileName: URL {
        
        let filename = AppSystem.shared.sysLogFileName

        let fileUrl = self.repository.root(for: .local)
            .appendingPathComponent(SYS_FOLDER_NAME)
            .appendingPathComponent(filename)
        
        return fileUrl
        
    }

    private var sysDiagnoseFileName: URL {
        
        let filename = AppSystem.shared.sysDiagnoseFileName

        let fileUrl = self.repository.root(for: .local)
            .appendingPathComponent(SYS_FOLDER_NAME)
            .appendingPathComponent(filename)
        
        return fileUrl
        
    }

    private var sysErrorFileName: URL {
        
        let filename = AppSystem.shared.sysErrorFileName

        let fileUrl = self.repository.root(for: .local)
            .appendingPathComponent(SYS_FOLDER_NAME)
            .appendingPathComponent(filename)
        
        return fileUrl
        
    }
    
    private func createFileIfNotExistent(filename: URL, content: Data) -> Void {
        
        let fileExists = repository.fileExists(name: filename)
        
        switch fileExists {
        case .success(let exists):

            if (exists) { break }
            AppSystem.shared.logDiagnose(message: "File \(filename.lastPathComponent) does not Exist!")
            _ = repository.createFile(filename: filename, data: content)

        case .failure(let repositoryError):
            AppSystem.shared.logException(error: repositoryError, file: #file, line: #line - 3)
            
        }
        
    }

    private func reload() -> Void { self.initializePublishers() }
    
}
