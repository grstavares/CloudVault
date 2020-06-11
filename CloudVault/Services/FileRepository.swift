//
//  FileRepository.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 29.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import Combine

enum FileRepositoryError: Error {

    case unableToLocateContainerRootFolder
    case unableToAccessDisk
    case folderDoNotExist(String)
    case undefined
    
    public var localizedDescription: String {
        
        switch self {
        case .unableToAccessDisk: return "Unable To Access Storage!"
        case .unableToLocateContainerRootFolder: return "Container not Configured to be used on this Application!"
        case .folderDoNotExist(let folderName): return "Folder does not Exist -> \(folderName)!"
        default: return "Error not identified!"
        }
        
    }
    
}

enum FileRepositoryAcceptedType {
    case image
    case text
    case pdf
    case movie
    case data
}

enum FileRepositoryEnabledContainer {
    case local
    case appGroup
    case iCloud
    case remote(baseUrl:URL)
}

typealias RepositoryOperationOutput = Result<Bool, FileRepositoryError>
typealias RepositoryExistsOutput = Result<Bool, FileRepositoryError>
typealias ReposityListOutput = Result<[String], FileRepositoryError>

class FileRepository {
    
    public static var shared = FileRepository()
    
    private init() { }
    
    public var documentsDirectory: URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    public var temporaryDirectory: URL { FileManager.default.temporaryDirectory }
    
    private var groupContainer: URL? {
        
        if let groupContainerId = AppConstants.appGroupId, let shared = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupContainerId) {
            return shared
        } else { return nil }
        
    }
    
    public func createFolder(folderName: String, inContainer container: FileRepositoryEnabledContainer) -> RepositoryOperationOutput {
        
        guard let baseUrl = self.getBaseUrl(for: container) else {
            AppSystem.shared.logException(error: FileRepositoryError.unableToLocateContainerRootFolder, file: #file, line: #line)
            return Result.failure(.unableToLocateContainerRootFolder)
        }
        
        let folderUrl = baseUrl.appendingPathComponent(folderName)
        do {
            try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
            AppSystem.shared.logOperation(message: "Folder \(folderName) created!", file: #file, line: #line)
            return Result.success(true)
        } catch  { return Result.failure(self.parseError(error: error, inLine: #line - 5)) }
        
    }
    
    public func listFiles(onFolder folder: String? = nil, using container: FileRepositoryEnabledContainer = .local) -> ReposityListOutput {
        
        guard let baseUrl = self.getBaseUrl(for: container) else {
            AppSystem.shared.logException(error: FileRepositoryError.unableToLocateContainerRootFolder, file: #file, line: #line)
            return Result.failure(.unableToLocateContainerRootFolder)
        }
        
        do {

            let path = folder != nil ? baseUrl.appendingPathComponent(folder!) : baseUrl
            
//            let folderExists = self.folderExists(name: folder, inContainer: container)
//
//            switch folderExists {
//            case .failure(let error):
//                AppSystem.shared.logException(error: error, file: #file, line: #line)
//                return Result.failure(error)
//
//            case .success(let exists):

//                guard exists else {
//                    AppSystem.shared.logException(error: FileRepositoryError.folderDoNotExist(path.absoluteString), file: #file, line: #line)
//                    return Result.failure(.folderDoNotExist(path.absoluteString))
//                }
                
                let directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
                let fileNames = directoryContents.map{ $0.absoluteString }
                
                AppSystem.shared.logOperation(message: "Found \(fileNames.count) files on Folder \(path.absoluteString)", file: #file, line: #line)
                
                return Result.success(fileNames)
                                
//            }

        } catch { return Result.failure(self.parseError(error: error, inLine: #line - 5)) }
        
    }
    
    public func saveWrapper(withName filename: String, fileWrapper: FileWrapper, using container: FileRepositoryEnabledContainer = .local) -> RepositoryOperationOutput {
        
        guard let baseUrl = self.getBaseUrl(for: container) else {
            AppSystem.shared.logException(error: FileRepositoryError.unableToLocateContainerRootFolder, file: #file, line: #line)
            return Result.failure(.unableToLocateContainerRootFolder)
        }
        
        do {
            let url = baseUrl.appendingPathComponent(filename)
            try fileWrapper.write(to: url, options: .atomic, originalContentsURL: nil)
            AppSystem.shared.logDiagnose(message: "File \(url.absoluteString) saved!", file: #file, line: #line)
            return Result.success(true)
        } catch { return Result.failure(self.parseError(error: error, inLine: #line - 5))}
        
    }
    
    public func saveFile(withName filename: String, data: Data, ofType: FileRepositoryAcceptedType, using container: FileRepositoryEnabledContainer = .local) -> RepositoryOperationOutput {
        
        guard let baseUrl = self.getBaseUrl(for: container) else {
            AppSystem.shared.logException(error: FileRepositoryError.unableToLocateContainerRootFolder, file: #file, line: #line)
            return Result.failure(.unableToLocateContainerRootFolder)
        }
        
        do {
            let url = baseUrl.appendingPathComponent(filename)
            try data.write(to: url) // FileManager.default.createFile(atPath: url.absoluteString, contents: data)
            AppSystem.shared.logDiagnose(message: "File \(url.absoluteString) saved!", file: #file, line: #line)
            return Result.success(true)
        } catch { return Result.failure(self.parseError(error: error, inLine: #line - 5))}
        
    }
    
    public func saveToUrl(url: URL, data: Data) -> RepositoryOperationOutput {
        
        do {
            try data.write(to: url) // FileManager.default.createFile(atPath: url.absoluteString, contents: data)
            AppSystem.shared.logDiagnose(message: "File \(url.absoluteString) saved!", file: #file, line: #line)
            return Result.success(true)
        } catch { return Result.failure(self.parseError(error: error, inLine: #line - 5))}
        
    }

    public func removeFile(withName filename: String, using container: FileRepositoryEnabledContainer = .local) -> RepositoryOperationOutput {
        
        guard let baseUrl = self.getBaseUrl(for: container) else {
            AppSystem.shared.logException(error: FileRepositoryError.unableToLocateContainerRootFolder, file: #file, line: #line)
            return Result.failure(.unableToLocateContainerRootFolder)
        }
        
        do {
            let url = baseUrl.appendingPathComponent(filename)
            try FileManager.default.removeItem(at: url)
            AppSystem.shared.logDiagnose(message: "File \(url.absoluteString) removed!", file: #file, line: #line)
            return Result.success(true)
        } catch { return Result.failure(self.parseError(error: error, inLine: #line - 5))}
        
    }
    
    public func clearFolder(withName folderName: String, using container: FileRepositoryEnabledContainer = .local) -> RepositoryOperationOutput {
        
        guard self.getBaseUrl(for: container) != nil else {
            AppSystem.shared.logException(error: FileRepositoryError.unableToLocateContainerRootFolder, file: #file, line: #line)
            return Result.failure(.unableToLocateContainerRootFolder)
        }
        
        let listFolder = listFiles(onFolder: folderName, using: container)
        switch listFolder {
        case .success(let content):
            
            do {

                let urlsToRemove = content
                    .map { URL(string: $0) }
                    .compactMap { $0 }
                    
                try urlsToRemove.forEach({ print("Removing \($0.absoluteString)"); try FileManager.default.removeItem(at: $0) })
                AppSystem.shared.logDiagnose(message: "\(urlsToRemove.count) Files  removed from \(folderName)!", file: #file, line: #line)
                return Result.success(true)
                
            } catch { return Result.failure(self.parseError(error: error, inLine: #line - 5))}
            
        case .failure(let error):
            return Result.failure(error)
        }
        
    }
    
    public func fileExists(name filename: String, inContainer container: FileRepositoryEnabledContainer = .local) -> RepositoryExistsOutput {
        
        guard let baseUrl = self.getBaseUrl(for: container) else {
            AppSystem.shared.logException(error: FileRepositoryError.unableToLocateContainerRootFolder, file: #file, line: #line)
            return Result.failure(.unableToLocateContainerRootFolder)
        }
        
        let url = baseUrl.appendingPathComponent(filename)
        let exists = FileManager.default.fileExists(atPath: url.absoluteString)
        return Result.success(exists)
        
    }

    public func folderExists(name foldername: String?, inContainer container: FileRepositoryEnabledContainer = .local) -> RepositoryExistsOutput {
        
        guard let baseUrl = self.getBaseUrl(for: container) else {
            AppSystem.shared.logException(error: FileRepositoryError.unableToLocateContainerRootFolder, file: #file, line: #line)
            return Result.failure(.unableToLocateContainerRootFolder)
        }
        
        let url = foldername != nil ? baseUrl.appendingPathComponent(foldername!) : baseUrl
        
        var isDir : ObjCBool = false
        print("Checking \(url.absoluteString)")
        let exists = FileManager.default.fileExists(atPath: url.absoluteString, isDirectory: &isDir)
        return Result.success(exists && isDir.boolValue)
        
    }
    
    public func fileType(url: URL) -> FileRepositoryAcceptedType {
        
        let fileExtension = url.pathExtension
        switch fileExtension.lowercased() {
        case "pdf": return .pdf
        case "jpg", "jpeg", "png": return .image
        case "txt", "md": return .text
        default: return .data
        }
        
    }
    
    private func getBaseUrl(for container: FileRepositoryEnabledContainer) -> URL? {
        
        switch container {
        case .local:
            return self.documentsDirectory
        case .appGroup:
            return self.groupContainer
        default:
            return self.documentsDirectory
        }
        
    }
    
    private func parseError(error: Error, inLine line: Int = 0) -> FileRepositoryError {
        AppSystem.shared.logException(error: error, file: #file, line:line)
        return .undefined
    }
    
}
