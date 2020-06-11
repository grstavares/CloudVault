//
//  Repository.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 08.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation

public enum FileRepositoryError: Error, Equatable {

    case unableToLocateContainerRootFolder
    case unableToAccessDisk
    case unableToLoadDataFromFile
    case permissionDenied
    case fileDoNotExist(String)
    case folderAlreadyExist(String)
    case folderDoNotExist(String)
    case undefined

    public var localizedDescription: String {

        switch self {
        case .unableToAccessDisk: return NSLocalizedString(RepositoryLocatizationKey.unableToAccessDisk.rawValue, comment: "Unable To Access Storage!")
        case .unableToLocateContainerRootFolder: return NSLocalizedString(RepositoryLocatizationKey.unableToLocateRootFolder.rawValue, comment: "Container not Configured to be used on this Application!")
        case .unableToLoadDataFromFile: return NSLocalizedString(RepositoryLocatizationKey.unableToLoadDataFromFile.rawValue, comment: "Can not load data from File!")
        case .permissionDenied: return NSLocalizedString(RepositoryLocatizationKey.permissionDenied.rawValue, comment: "Unable to access file in Disk!")
        case .fileDoNotExist(let filename): return "\(NSLocalizedString(RepositoryLocatizationKey.fileDoNotExist.rawValue, comment: "File does not Exist")) -> \(filename)!"
        case .folderAlreadyExist(let folderName): return "\(NSLocalizedString(RepositoryLocatizationKey.folderAlreadyExist.rawValue, comment: "Folder Already Exist")) -> \(folderName)!"
        case .folderDoNotExist(let folderName): return "\(NSLocalizedString(RepositoryLocatizationKey.folderDoNotExist.rawValue, comment: "Folder does not Exist")) -> \(folderName)!"
        default: return "Error not identified!"
        }

    }

}

public typealias RepositoryOperationOutput = Result<Bool, FileRepositoryError>
public typealias RepositoryExistsOutput = Result<Bool, FileRepositoryError>
public typealias ReposityFileOutput = Result<RepositoryFile, FileRepositoryError>
public typealias ReposityListOutput = Result<[RepositoryFile], FileRepositoryError>

public class Repository {
   
    enum AcceptedFileType {
        case image
        case text
        case pdf
        case movie
        case data
    }

    public enum EnabledContainer {
        case local
        case appGroup
        case iCloud
        case remote(baseUrl:URL)
    }
    
    private var appGroupId: String?
    private let serialQueue = DispatchQueue(label: "\(AppSystem.serialQueueId).repository", qos: .background)
    
    public init(appGroupId: String? = nil) {
        self.appGroupId = appGroupId
    }
    
    private var localDocumentsFolder: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    public func root(for container: EnabledContainer) -> URL {
        
        switch container {
            
        case .local: return self.localDocumentsFolder
        
        case.appGroup:
            
            guard let appGroupId = self.appGroupId else {
                return self.localDocumentsFolder
            }
            
            guard let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
                return self.localDocumentsFolder
            }
            
            return groupContainer
            
        default:
            return self.localDocumentsFolder
        }
        
    }
    
    public func fileExists(name filename: URL) -> RepositoryExistsOutput {
        
        let exists = FileManager.default.fileExists(atPath: filename.path)
        return Result.success(exists)
        
    }

    public func folderExists(name foldername: URL) -> RepositoryExistsOutput {
               
        var isDir : ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: foldername.path, isDirectory: &isDir)
        return Result.success(exists && isDir.boolValue)
        
    }
    
    public func createFolder(name foldername: URL) -> RepositoryExistsOutput {
        
        do {
            try FileManager.default.createDirectory(at: foldername, withIntermediateDirectories: true, attributes: nil)
            AppSystem.shared.logOperation(message: "Folder \(foldername) created!", file: #file, line: #line)
            return Result.success(true)
        } catch  { return Result.failure(self.parseError(error: error, inLine: #line - 5)) }
        
    }
    
    public func listFolder(foldername: URL, recursive: Bool = false) -> ReposityListOutput {
        
        do {
            
            let directoryContents = try FileManager.default.contentsOfDirectory(at: foldername, includingPropertiesForKeys: nil)
            let fileDescriptions = directoryContents.map { RepositoryFile(url: $0) }
            AppSystem.shared.logOperation(message: "Found \(directoryContents.count) files on Folder \(foldername.lastPathComponent)")
            
            return Result.success(fileDescriptions)

        } catch { return Result.failure(self.parseError(error: error, inLine: #line - 5)) }
            
    }
    
    public func loadFile(filename: URL) -> ReposityFileOutput {
        
        let fileExists = self.fileExists(name: filename)
        switch fileExists {
        case .success(let found):
            
            if found { return .success(RepositoryFile(url: filename))
            } else { return .failure(.fileDoNotExist(filename.lastPathComponent)) }
            
        case .failure(let error):
            return Result.failure(self.parseError(error: error, inLine: #line - 8))
        }
        
    }
    
    public func loadFileData(filename: URL) -> ReposityFileOutput {

        do {

            let fileExists = self.fileExists(name: filename)
            switch fileExists {
            case .success(let found):
                
                if found {
                    let fileHandler = try FileHandle(forReadingFrom: filename)
                    let data = fileHandler.readDataToEndOfFile()
                    try fileHandler.close()
                    return .success(RepositoryFile(url: filename, data: data))
                } else { return .failure(.fileDoNotExist(filename.lastPathComponent)) }
                
            case .failure(let error):
                return Result.failure(self.parseError(error: error, inLine: #line - 8))
            }
            
        } catch {
            print(error)
            let fileError = self.parseError(error: error)
            AppSystem.shared.logException(error: fileError)
            return .failure(fileError)
        }

    }
    
    public func moveFile(from: URL, to: URL) -> RepositoryOperationOutput {
        
        do {
            try FileManager.default.moveItem(at: from, to: to)
            return .success(true)
        } catch {
            print(error)
            let fileError = self.parseError(error: error)
            AppSystem.shared.logException(error: fileError)
            return .failure(fileError)
        }
        
    }
    
    public func saveFileWrapper(filename: URL, fileWrapper: FileWrapper) -> RepositoryOperationOutput {
        
        do {
            try fileWrapper.write(to: filename, options: .atomic, originalContentsURL: nil)
            AppSystem.shared.logOperation(message: "File \(filename.lastPathComponent) created!", file: #file, line: #line - 1)
            return .success(true)
        } catch {
            let fileError = self.parseError(error: error)
            AppSystem.shared.logException(error: fileError)
            return .failure(fileError)
        }
        
    }
    
    public func createFile(filename: URL, data: Data) -> RepositoryOperationOutput {

        do {
            try data.write(to: filename, options: .atomic)
            AppSystem.shared.logOperation(message: "File \(filename.lastPathComponent) created!", file: #file, line: #line - 1)
            return .success(true)
        } catch {
            let fileError = self.parseError(error: error)
            AppSystem.shared.logException(error: fileError)
            return .failure(fileError)
        }
        
    }
    
    public func appendToFile(filename: URL, data: Data) -> RepositoryOperationOutput {
                
        do {
            
            let handler = try FileHandle(forUpdating: filename)
            handler.seekToEndOfFile()
            handler.write(data)
            try handler.close()
            return .success(true)
            
        } catch { return Result.failure(self.parseError(error: error, inLine: #line - 3)) }
        
    }
    
    public func removeFile(filename: URL) -> RepositoryOperationOutput {
        
        do {
            try FileManager.default.removeItem(at: filename)
            AppSystem.shared.logOperation(message: "File \(filename.absoluteString) removed!", file: #file, line: #line)
            return .success(true)
        } catch { return Result.failure(self.parseError(error: error, inLine: #line - 3)) }
        
    }
    
    private func parseError(error: Error, inLine line: Int = 0) -> FileRepositoryError {
        print(error.localizedDescription)
        
        let nsError = error as NSError
        let repoError: FileRepositoryError?
        switch nsError.code {
        case 257: repoError = .permissionDenied
        default: repoError = .undefined
        }
        
        AppSystem.shared.logException(error: repoError, file: #file, line:line)
        return repoError!
        
    }
    
}
