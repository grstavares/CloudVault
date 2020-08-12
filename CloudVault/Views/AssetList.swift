//
//  AssetList.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 18.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI
import Combine

struct AssetList: View {
    
    let data = AppRepository.shared
    let assetType: AssetType
    
    @State var confirmRemoved: Bool = false
    
    var body: some View {
        
        List {
            
            ForEach(self.data.assets.filter{ $0.asset.type == assetType }) { asset in
                NavigationLink(destination: AssetView(package: asset)) {
                    Text(asset.url?.lastPathComponent ?? "NoName")
                }
            }.onDelete { indexSet in

                indexSet.forEach { index in
                    
                    let package = self.data.assets.filter{ $0.asset.type == self.assetType }[index]
                    let removed = AppRepository.shared.removePackage(package: package)
                    self.confirmRemoved = removed
                }

            }

        }.navigationBarTitle(self.titleFor(assetType: self.assetType).split(separator: "-")[2])
        
    }
    
    private func titleFor(assetType: AssetType) -> String {
        
        switch assetType {
        case .url: return NSLocalizedString("AssetList-NavigationTitle-Web links", comment: "Main View Navigation Button")
        case .image: return NSLocalizedString("AssetList-NavigationTitle-Photos", comment: "Main View Navigation Button")
        case .movie: return NSLocalizedString("AssetList-NavigationTitle-Videos", comment: "Main View Navigation Button")
        case .pdf: return NSLocalizedString("AssetList-NavigationTitle-Documents", comment: "Main View Navigation Button")
        case .text: return NSLocalizedString("AssetList-NavigationTitle-Annotations", comment: "Main View Navigation Button")
        case .contact: return NSLocalizedString("AssetList-NavigationTitle-Contacts", comment: "Main View Navigation Button")
        case .password: return NSLocalizedString("AssetList-NavigationTitle-Passwords", comment: "Main View Navigation Button")
        case .creditCard: return NSLocalizedString("AssetList-NavigationTitle-CreditCard", comment: "Main View Navigation Button")
        case .data: return NSLocalizedString("MAssetList-NavigationTitle-Data", comment: "Main View Navigation Button")
        }
    }
    
}
