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
fileprivate let DATA_FILENAME = "content.data"

extension AssetPackage {
    
    private static func from(disk wrapper: FileWrapper, with url: URL) -> AssetPackage? {
        
        guard let wrapperMetadata = wrapper.fileWrappers?[METADA_FILENAME],
            let encodedMetadata = wrapperMetadata.regularFileContents,
            let decodedMetadata = try? AppSystem.shared.decoder.decode(AssetMetadata.self, from: encodedMetadata)
            else { return nil }
                
        guard let wrapperAsset = wrapper.fileWrappers?[ASSET_FILENAME],
            let encodedAsset = wrapperAsset.regularFileContents,
            let codableAsset = try? AppSystem.shared.decoder.decode(CodableAsset.self, from: encodedAsset)
            else { return nil }

        guard let wrapperData = wrapper.fileWrappers?[DATA_FILENAME],
            let content = wrapperData.regularFileContents
            else { return nil }
        
        let asset = AssetPackage.createAsset(encrypted: decodedMetadata.encrypted, info: codableAsset, content: content)
        let package = AssetPackage.using(asset: asset, url: url, metadata: decodedMetadata)
        return package
        
    }
    
    static func from(url: URL) -> AssetPackage? {
        
        if url.isFileURL {

            guard let wrapper = try? FileWrapper(url: url, options: .immediate) else {
                return nil
            }

            return AssetPackage.from(disk: wrapper, with: url)
            
        } else {
        
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
        fileWrapper.addRegularFile(withContents: self.asset.data, preferredFilename: DATA_FILENAME)
        return fileWrapper
        
    }
    
    private var encodeAsset: Data? {
    
        let codable = CodableAsset(name: self.asset.name, type: self.asset.type)
        return try? AppSystem.shared.encoder.encode(codable)
    
    }
    
    private func loadFromUrl(url: URL) -> Void {
        AppSystem.shared.logDiagnose(message: "Load Remote Not Implemented")
    }
    
    private static func createAsset(encrypted: Bool, info: CodableAsset, content: Data) -> Asset {
        
        let assetName = info.name
        let assetType = info.type
        return encrypted ? EncryptedAsset(name: assetName, type: assetType, data: content) : UnencryptedAsset(name: assetName, type: assetType, data: content)

    }
    
}
