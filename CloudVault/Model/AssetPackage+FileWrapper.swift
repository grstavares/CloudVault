//
//  AssetPackage+FileWrapper.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 08.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation

fileprivate let METADA_FILENAME = "metadata.data"
fileprivate let ASSET_FILENAME = "asset.data"

extension AssetPackage {
    
    private static func from(disk wrapper: FileWrapper, with url: URL) -> AssetPackage? {
        
        guard let wrapperMetadata = wrapper.fileWrappers?[METADA_FILENAME],
            let encodedMetadata = wrapperMetadata.regularFileContents,
            let decodedMetadata = try? AppSystem.shared.decoder.decode(AssetMetadata.self, from: encodedMetadata)
            else { return nil }
                
        guard let wrapperAsset = wrapper.fileWrappers?[ASSET_FILENAME],
            let encodedAsset = wrapperAsset.regularFileContents
            else { return nil }
        
        let encrypted = decodedMetadata.encrypted
        
        if encrypted, let decodedAsset = try? AppSystem.shared.decoder.decode(EncryptedAsset.self, from: encodedAsset) {
            return AssetPackage.from(asset: decodedAsset, url: url, metadata: decodedMetadata)
        }
        
        if let decodedAsset = try? AppSystem.shared.decoder.decode(UnencryptedAsset.self, from: encodedAsset) {
            return AssetPackage.from(asset: decodedAsset, url: url, metadata: decodedMetadata)
        }
        
        return nil
        
    }
    
    static func from(url: URL) -> AssetPackage? {
        
        if url.isFileURL {

            guard let wrapper = try? FileWrapper(url: url, options: .immediate) else {
                return nil
            }

            return AssetPackage.from(disk: wrapper, with: url)
            
        } else {
        
//            self.loadFromUrl(url: url)
            print("is not file")
            return nil  //FIXME
        }

    }
    
    public var fileWrapper: FileWrapper? {
     
        guard let encodedMetadata = try? AppSystem.shared.encoder.encode(self.metadata) else {
            AppSystem.shared.logException(error: Failure.unableToEncodeMetadata)
            return nil
        }
        
        guard let encodedAsset = self.encodeAsset else {
            AppSystem.shared.logException(error: Failure.unableToEncodeAsset)
            return nil
        }

        let fileWrapper = FileWrapper(directoryWithFileWrappers: [:])
        fileWrapper.addRegularFile(withContents: encodedMetadata, preferredFilename: METADA_FILENAME)
        fileWrapper.addRegularFile(withContents: encodedAsset, preferredFilename: ASSET_FILENAME)
        return fileWrapper
        
    }
    
    private var encodeAsset: Data? {
    
        let encrypted = self.metadata.encrypted
        if encrypted {
            guard let typed = self.asset as? EncryptedAsset else { return nil }
            return try? AppSystem.shared.encoder.encode(typed)
        } else {
            guard let typed = self.asset as? UnencryptedAsset else { return nil }
            return try? AppSystem.shared.encoder.encode(typed)
        }
    
    }
    
    private func loadFromUrl(url: URL) -> Void {
        AppSystem.shared.logDiagnose(message: "Load Remote Not Implemented")
    }
    
}
