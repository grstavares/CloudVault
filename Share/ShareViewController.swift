//
//  ShareViewController.swift
//  Share
//
//  Created by Gustavo Tavares on 29.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
   
    let dataType = kUTTypeData as String
    let imageType = kUTTypeImage as String
    let pdfType = kUTTypePDF as String
    let urlType = kUTTypeURL as String
    let movType = kUTTypeMovie as String
    let videoType = kUTTypeVideo as String
    let txtType = kUTTypeText as String
    let vcardType = kUTTypeVCard as String
    let emailType = kUTTypeEmailMessage as String
    let fileType = kUTTypeFileURL as String
    
    let updateQueue = DispatchQueue(label: "\(AppSystem.shared.bundleName).shareExtension")
    
    var numberOfFilesToBeProcessed: Int = 0
    var numberOfFilesProcessed: Int = 0
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    override func didSelectPost() {
               
        guard let extensionItems = extensionContext?.inputItems else {
            AppSystem.shared.logDiagnose(message: "Share Extension didn't received any Input Item!", file: #file, line: #line)
            return
        }

        let shareText = extensionItems
            .map{ item in item as? NSExtensionItem }
            .map { $0?.attributedContentText }
            .compactMap { $0 }
        
        print(shareText)
        
        let itemsToBeProcessed = extensionItems
            .map{ item in item as? NSExtensionItem }
            .filter({ $0 != nil })
            .map { item in item!.attachments ?? [] }
            .flatMap({ $0 })
            .filter { filterAcceptedContentType(item: $0) != nil }

        self.numberOfFilesToBeProcessed = itemsToBeProcessed.count
        self.numberOfFilesProcessed = 0
        
        if (self.numberOfFilesToBeProcessed == 0) { self.endProcessing() }
        
        itemsToBeProcessed.forEach { itemProvider in

            if let contentType = filterAcceptedContentType(item: itemProvider) {

                itemProvider.loadItem(forTypeIdentifier: contentType) { [self] result, error in
                    
                    guard error == nil else {
                        AppSystem.shared.logException(error: error, file: #file, line: #line)
                        self.updateProcessingCount(success: false)
                        return
                    }

                    guard let secureContent = result else {
                        self.updateProcessingCount(success: false)
                        return
                    }

                    if let package = self.decodeContent(content: secureContent, ofType: contentType) {
                        let success = AppRepository.addToDropBox(package: package)
                        self.updateProcessingCount(success: success)
                    } else { self.updateProcessingCount(success: false) }
                                                
                }
                
            } else { self.updateProcessingCount(success: false) }
   
        }
        
    }

    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    override func configurationItems() -> [Any]! { return [] }

    private func updateProcessingCount(success: Bool = true) -> Void {
        
        self.updateQueue.sync { self.numberOfFilesProcessed = numberOfFilesProcessed + 1 }
        
        let numberOfFilesProcessedEqualExpected = self.numberOfFilesProcessed == self.numberOfFilesToBeProcessed
        let counterGreaterThanExpected = self.numberOfFilesProcessed > self.numberOfFilesToBeProcessed
        
        if numberOfFilesProcessedEqualExpected || counterGreaterThanExpected {
            self.endProcessing()
        }
        
    }
    
    private func endProcessing() -> Void {
        AppSystem.shared.logOperation(message: "File Processing Finished! \(self.numberOfFilesProcessed) files processed!")
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func filterAcceptedContentType(item: NSItemProvider) -> String? {

        let orderedTypes = [imageType, pdfType, fileType, urlType, videoType, movType, txtType, emailType, vcardType, dataType]
        for contentType in orderedTypes {
            if item.hasItemConformingToTypeIdentifier(contentType) { return contentType }
        }
        
        return nil
    }
    
    private func decodeContent(content: NSSecureCoding, ofType contentType: String) -> AssetPackage? {
        
        print(contentType)
        switch contentType {
        
        case pdfType, videoType, movType, imageType:
            
            guard let url = self.tryCastAsURL(content: content) else { return nil }
            return self.packageFromUrl(url: url, forType: contentType)
            
        case urlType:
            
            if let url = self.tryCastAsURL(content: content), let data = url.absoluteString.data(using: .utf8) {
                
                let assetName = url.lastPathComponent
                let assetType = AssetType.fromUniversalType(type: contentType, withExtension: nil)
                let asset = UnencryptedAsset(name: assetName, type: assetType, data: data)
                let metadata = AssetMetadata(id: ULID().stringValue, sharedDate: Date(), filename: assetName, encrypted: false, showThumbnail: true)
                let package = AssetPackage.new(asset: asset, metadata: metadata)
                return package

            } else { return nil }

        case vcardType:

            print("Is a VCard")
            return nil

        case emailType:
            
            print("Is a Email")
            return nil
            
        case txtType:
            
            print("Is a Text")
            return nil
            
        case fileType:
            
            print("I'm a file type")
            
            guard let url = self.tryCastAsURL(content: content) else { return nil }
            return self.packageFromUrl(url: url, forType: contentType)
            
        case dataType:
            
            if let url = self.tryCastAsURL(content: content) {
                return self.packageFromUrl(url: url, forType: contentType)
            }
            
            if let asString = content as? String {

                if let sharedUrl = URL(string: asString) {
                    print(sharedUrl.absoluteURL)
                }
                
            }

            return nil
            
        default:
            
            print("Unable to Decode")
            return nil
        }
        
    }

    private func tryCastAsURL(content: NSSecureCoding) -> URL? {
        guard let nsUrl = content as? NSURL else { return nil }
        return nsUrl as URL
    }

    private func packageFromUrl(url: URL, forType contentType: String) -> AssetPackage? {
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        let assetName = url.lastPathComponent
        let assetType = AssetType.fromUniversalType(type: contentType, withExtension: url.pathExtension)
        print(assetType)
        let asset = UnencryptedAsset(name: assetName, type: assetType, data: data)
        let metadata = AssetMetadata(id: ULID().stringValue, sharedDate: Date(), filename: assetName, encrypted: false, showThumbnail: true)
        let package = AssetPackage.new(asset: asset, metadata: metadata)
        return package
        
    }
    
}
