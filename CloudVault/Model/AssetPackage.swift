//
//  AssetPackage.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 09.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
class AssetPackage: Identifiable, ObservableObject {
 
    enum Failure: Error {
        case unableToEncodeMetadata
        case unableToEncodeAsset
        case unableToDecodeMetadata
        case unableToDecodeAsset
    }
    
    enum Status {
        case new, loading, loaded, failed(Failure)
    }
    
    var id: String { self.metadata.id }

    @Published private (set) var status: Status
    @Published private (set) var metadata: AssetMetadata
    @Published private (set) var asset: Asset
    public let url: URL?
    
    private init(asset: Asset, url: URL?, metadata: AssetMetadata, status: Status = .loaded) {
        
        self.asset = asset
        self.url = url
        self.metadata = metadata
        self.status = url == nil ? .new : .loaded
        
    }
    
}

extension AssetPackage {

    static func new(asset: UnencryptedAsset, metadata existent: AssetMetadata? = nil) -> AssetPackage  {
        
        let metadata = existent ?? AssetMetadata(id: ULID().stringValue, sharedDate: Date(), filename: asset.name, encrypted: false, showThumbnail: true)
        return AssetPackage(asset: asset, url: nil, metadata: metadata, status: .new)
        
    }
    
    static func from(asset: UnencryptedAsset, url: URL?, metadata existent: AssetMetadata? = nil) -> AssetPackage  {
        
        let metadata = existent ?? AssetMetadata(id: ULID().stringValue,sharedDate: Date(), filename: asset.name, encrypted: false, showThumbnail: true)
        return AssetPackage(asset: asset, url: url, metadata: metadata)
        
    }
    
    static func from(asset: EncryptedAsset, url: URL?, metadata existent: AssetMetadata? = nil) -> AssetPackage {
        
        let metadata = existent ?? AssetMetadata(id: ULID().stringValue,sharedDate: Date(), filename: asset.name, encrypted: true, showThumbnail: true)
        return AssetPackage(asset: asset, url: url, metadata: metadata)
        
    }
    
    static func using(asset: Asset, url: URL, metadata: AssetMetadata) -> AssetPackage {
        return AssetPackage(asset: asset, url: url, metadata: metadata)
    }
    
}

extension AssetPackage: Hashable {

    static func == (lhs: AssetPackage, rhs: AssetPackage) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
