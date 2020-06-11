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
private let SYS_FOLDER_NAME = "System"
private let PACKAGE_EXTENSION = "pckg"
private let SYS_LOG_INITIALIZATION_CONTENT = "LOG INITIALIZATION"
private let SYS_LOG_PREFIX = "operations"
private let SYS_DIAGNOSE_PREFIX = "diagnose"
private let SYS_ERROR_PREFIX = "errors"

class AppRepository: ObservableObject {
    
    private static var _shared: AppRepository?
    
    public static var shared:AppRepository {
        
        if AppRepository._shared == nil { AppRepository._shared = AppRepository() }
        return AppRepository._shared!
        
    }
    
    private var repository: Repository
    private var cancellables: [Cancellable] = []
    
    @Published var inbox: [RepositoryFile] = []
    @Published var assets: [RepositoryFile] = []
    
    public init(repository: Repository = Repository(appGroupId: AppSystem.appGroupId)) {
    
        self.repository = repository
        self.initializeListeners()
        self.initializeFolders()
        self.initializeFiles()
        self.reload()
        
    }
           
    public func getFileListFromSharedFolder() -> ReposityListOutput {
        let localroot = self.repository.root(for: .appGroup)
        let datafolder = localroot.appendingPathComponent(INBOX_FOLDER_NAME)
        return repository.listFolder(foldername: datafolder)
    }
    
    public func getFileListFromDataFolder() -> ReposityListOutput {
        
        let localroot = self.repository.root(for: .local)
        let datafolder = localroot.appendingPathComponent(DATA_FOLDER_NAME)
        return repository.listFolder(foldername: datafolder)

    }
    
    public func getFileListFromSystemFolder() -> ReposityListOutput {
        
        let localroot = self.repository.root(for: .local)
        let datafolder = localroot.appendingPathComponent(SYS_FOLDER_NAME)
        return repository.listFolder(foldername: datafolder)

    }
    
    public func clearInboxFolder() -> Bool {
        
        self.getFileListFromSharedFolder()
            .getValidValues()
            .forEach { (file: RepositoryFile) in _ = self.repository.removeFile(filename: file.url) }
        
        return true

    }

    public func clearDataFolder() -> Bool {
        
        self.getFileListFromDataFolder()
            .getValidValues()
            .forEach { (file: RepositoryFile) in _ = self.repository.removeFile(filename: file.url) }
        
        return true
    }

    public func clearSystemFolder() -> Bool {
        
        self.getFileListFromSystemFolder()
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
           
    private func initializeListeners() -> Void {
        
        let backgroundQueue = DispatchQueue(label: "AppRepositoryListeners", qos: .background)
        
        self.cancellables.append(AppSystem.shared.$operations
            .subscribe(on: backgroundQueue)
            .receive(on: RunLoop.main)
            .sink { if !$0.isEmpty { self.appendLogToFile(message: $0, in: self.sysLogFileName) } }
        )
        
        self.cancellables.append(AppSystem.shared.$diagnoses
            .subscribe(on: backgroundQueue)
            .receive(on: RunLoop.main)
            .sink { if !$0.isEmpty { self.appendLogToFile(message: $0, in: self.sysDiagnoseFileName) } }
        )
        
        self.cancellables.append(AppSystem.shared.$exceptions
            .subscribe(on: backgroundQueue)
            .compactMap{ $0 }
            .receive(on: RunLoop.main)
            .sink { self.appendLogToFile(message: $0.localizedDescription, in: self.sysErrorFileName) }
        )
        
    }
    
    private var sysLogFileName: URL {
        
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let filename = "\(year)-\(String(format: "%02d", month))_\(SYS_LOG_PREFIX).log"

        let fileUrl = self.repository.root(for: .local)
            .appendingPathComponent(SYS_FOLDER_NAME)
            .appendingPathComponent(filename)
        
        return fileUrl
        
    }

    private var sysDiagnoseFileName: URL {
        
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let filename = "\(year)-\(String(format: "%02d", month))_\(SYS_DIAGNOSE_PREFIX).log"

        let fileUrl = self.repository.root(for: .local)
            .appendingPathComponent(SYS_FOLDER_NAME)
            .appendingPathComponent(filename)
        
        return fileUrl
        
    }

    private var sysErrorFileName: URL {
        
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let filename = "\(year)-\(String(format: "%02d", month))_\(SYS_ERROR_PREFIX).log"

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

    private func reload() -> Void {
        self.inbox = self.getFileListFromSharedFolder().getValidValues()
        self.assets = self.getFileListFromDataFolder().getValidValues()
        self.objectWillChange.send()
    }
    
    deinit { cancellables.forEach { $0.cancel() } }
    
}
