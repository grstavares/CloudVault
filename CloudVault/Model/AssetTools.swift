//
//  AssetTools.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 08.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import CryptoKit

struct AssetTools {
    
    static func assetType(pathExtension: String) -> AssetType {
        
        switch pathExtension.lowercased() {
        case "txt", "md": return .text
        case "jpg", "jpeg", "png": return .image
        case "mov", "mp4": return .movie
        case "pdf": return .pdf
        default: return .data
        }
        
    }
    
    static func encrypt(data: Data) -> Data? {
    
        guard let cipherKey = AppSystem.shared.encriptionKey(for: AppSystem.encriptionContext) else {
            return nil
        }
        
        guard let cryptedBox = try? ChaChaPoly.seal(data, using: cipherKey) else {
            return nil
        }
        
        guard let sealedBox = try? ChaChaPoly.SealedBox(combined: cryptedBox.combined) else {
            return nil
        }
        
        return sealedBox.combined
        
    }
    
    static func decrypt(data: Data) -> Data? {
        
        guard let cipherKey = AppSystem.shared.encriptionKey(for: AppSystem.encriptionContext) else {
            return nil
        }
        
        guard let sealedBox = try? ChaChaPoly.SealedBox(combined: data) else {
            return nil
        }
        
        guard let decryptedData = try? ChaChaPoly.open(sealedBox, using: cipherKey) else {
            return nil
        }
        
        return decryptedData
        
    }
    
}
