//
//  InBox.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 29.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI
import UIKit
import Combine

struct FileList: View {
    
    @State var title: String
    @State var files: [RepositoryFile]
    
    var assets: [AssetPackage] { files.compactMap { AssetPackage.from(url: $0.url) } }
    
    var body: some View {
        print("calcularing FileList for \(title)")
        return NavigationView {
            List(assets) { asset in
                NavigationLink(destination: AssetPreview(package: asset)) {
                    Text(asset.url?.lastPathComponent ?? "NoName")
                    Spacer()
                    Text("Encrypted")
                }
            }.navigationBarTitle(Text(title))
        }
    }
    
}



struct InBox_Previews: PreviewProvider {
    static var previews: some View {
        FileList(title: "Preview", files:[])
    }
}
