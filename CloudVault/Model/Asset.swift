//
//  Asset.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 08.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
enum AssetType: String, Codable {
    case image
    case text
    case pdf
    case movie
    case data
}

protocol Asset {
    var name: String { get }
    var type: AssetType { get }
    var data: Data { get }
}



struct AssetMetadata: Codable {
    
    let sharedDate: Date
    let filename: String
    let encrypted: Bool
    let showThumbnail: Bool
    
}

extension AssetMetadata: Hashable, Equatable { }
