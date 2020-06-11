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
    
    let updateQueue = DispatchQueue(label: AppSystem.serialQueueId)
    
    var numberOfFilesToBeProcessed: Int = 0
    var numberOfFilesProcessed: Int = 0
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
               
        guard let extensionItems = extensionContext?.inputItems else {
            AppSystem.shared.logDiagnose(message: "Share Extension didn't received any Input Item!", file: #file, line: #line)
            return
        }
        
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
                        self.updateProcessingCount()
                        return
                    }
                     
                    guard let nsUrl = result as? NSURL else { return }

                    if let asset = UnencryptedAsset.from(url: nsUrl as URL) {
                        
                        let package = AssetPackage.from(asset: asset, url: nil)
                        let success = AppRepository.shared.saveOnSharedFolder(package: package)
                        self.updateProcessingCount(success: success)
                        
                    } else { self.updateProcessingCount() }
                                                
                }
                
            } else { self.updateProcessingCount() }
   
        }
        
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

    private func updateProcessingCount(success: Bool = true) -> Void {
        
        self.updateQueue.sync { print("one file processed => success \(success)!"); self.numberOfFilesProcessed = numberOfFilesProcessed + 1 }
        
        let numberOfFilesProcessedEqualExpected = self.numberOfFilesProcessed == self.numberOfFilesToBeProcessed
        let counterGreaterThanExpected = self.numberOfFilesProcessed > self.numberOfFilesToBeProcessed
        
        if numberOfFilesProcessedEqualExpected || counterGreaterThanExpected {
            print("end processeing!");
            self.endProcessing()
        }
        
    }
    
    private func endProcessing() -> Void {
        AppSystem.shared.logOperation(message: "File Processing Finished! \(self.numberOfFilesProcessed) files processed!")
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func filterAcceptedContentType(item: NSItemProvider) -> String? {
        
        let orderedTypes = [imageType, pdfType, dataType]
        for contentType in orderedTypes {
            if item.hasItemConformingToTypeIdentifier(contentType) { return contentType }
        }
        
        return nil
    }
    
}
