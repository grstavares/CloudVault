//
//  Asset.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 31.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import CryptoKit
import UIKit

struct EncryptedAsset: Asset {
 
    let name: String
    let type: AssetType
    let data: Data
    
    fileprivate init(name: String, type: AssetType, data: Data) {
        self.name = name
        self.type = type
        self.data = data
    }
    
}

extension EncryptedAsset {
    
    static func from(unencrypted: UnencryptedAsset) -> EncryptedAsset? {
        
        guard let ciphered = AssetTools.encrypt(data: unencrypted.data) else { return nil }
        
        let assetName = unencrypted.name
        return EncryptedAsset(name: assetName, type: unencrypted.type, data: ciphered)
        
    }
    
    var decrypted: Data? { AssetTools.decrypt(data: self.data) }
    
}

extension EncryptedAsset: Codable, Hashable, Equatable { }
