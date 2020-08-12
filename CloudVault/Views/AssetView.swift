//
//  AssetView.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 18.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI

struct AssetView: View {

    let package: AssetPackage
    
    var body: some View {
        
        contentView
            .navigationBarTitle(package.asset.name)

    }
    
    var contentView: some View {
    
        switch package.asset.type {
        
        case .url:
            
            guard let string = String(data: package.asset.data, encoding: .utf8),
                let url = URL(string: string) else {
                    return Text("Preview").eraseToAnyView()
            }
            
            return SafariView(url: url).eraseToAnyView()
            
        case .image:

            guard let uiImage = UIImage(data: package.asset.data) else { return UnableToDecrypt().eraseToAnyView() }
            let imageView = Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fit)
            return imageView.eraseToAnyView()

        case .movie:
            
            guard let url = AppRepository.shared.decryptToTemporaryUrl(package: package) else { return UnableToDecrypt().eraseToAnyView() }
            return VideoPlayerView(videoURL: url)
                .onDisappear { _ = AppRepository.shared.removeFile(url: url) }
                .eraseToAnyView()
        
        case .text:
            
            guard let content = String(data: package.asset.data, encoding: .utf8) else  {
                return Text("Preview").eraseToAnyView()
            }
            
            return Text(content).eraseToAnyView()
            
        case .pdf:
            
            let pdfView = PDFKitView(package.asset.data)
            return pdfView.eraseToAnyView()
            
        default:
            return Text("Preview").eraseToAnyView()
        }
        
    }
    
}
