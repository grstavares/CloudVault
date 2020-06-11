//
//  UnecryptedAsset.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 08.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import UIKit

struct UnencryptedAsset: Asset {
 
    let name: String
    let type: AssetType
    let data: Data
    
}

extension UnencryptedAsset {

    static func from(url: URL) -> UnencryptedAsset? {
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        let assetName = url.lastPathComponent
        let fileExtension = url.pathExtension
        let assetType = AssetTools.assetType(pathExtension: fileExtension)
        return UnencryptedAsset.init(name: assetName, type: assetType, data: data)
        
    }
    
    static func from(uiImage: UIImage, name: String?) -> UnencryptedAsset? {
        
        guard let data = uiImage.pngData() else { return nil }
        
        let assetName = name ?? "GenerateRandomName"
        return UnencryptedAsset.init(name: assetName, type: .image, data: data)
        
    }
    
}

extension UnencryptedAsset: Codable, Hashable, Equatable { }
