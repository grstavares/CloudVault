//
//  Asset.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 08.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import MobileCoreServices

enum AssetType: String, Codable {

    case url
    case contact
    case image
    case movie
    case pdf
    case text
    case password
    case creditCard
    case data
    
    static func fromUniversalType(type: String, withExtension fileExtension: String? = nil) -> AssetType {
        
        let dataType = kUTTypeData as String
        let imageType = kUTTypeImage as String
        let pdfType = kUTTypePDF as String
        let urlType = kUTTypeURL as String
        let movType = kUTTypeMovie as String
        let videoType = kUTTypeVideo as String
        let txtType = kUTTypeText as String
//        let vcardType = kUTTypeVCard as String
//        let emailType = kUTTypeEmailMessage as String
        let fileType = kUTTypeFileURL as String
        
        switch type {
        case pdfType: return .pdf
        case imageType: return .image
        case movType, videoType: return .movie
        case urlType: return .url
        case txtType: return .text
            
        case fileType:
            
            guard let fileExtension = fileExtension else { return .data }
            switch fileExtension.lowercased() {
            case "txt", "md": return .text
            default: return .data
            }
            
        case dataType:
            
            guard let fileExtension = fileExtension else { return .data }
            switch fileExtension.lowercased() {
            case "mp4", "mov": return .movie
            case "jpeg", "jpg", "png", "gif": return .image
            default: return .data
            }
        
        default: return .data
            
        }
        
    }
    
}

protocol Asset {
    var name: String { get }
    var type: AssetType { get }
    var data: Data { get }
}

struct AssetMetadata: Codable {
    
    let id: String
    let sharedDate: Date
    let filename: String
    let encrypted: Bool
    let showThumbnail: Bool
    
}

struct CodableAsset: Codable, Hashable, Equatable {
    let name: String
    let type: AssetType
}

extension AssetMetadata: Hashable, Equatable { }
