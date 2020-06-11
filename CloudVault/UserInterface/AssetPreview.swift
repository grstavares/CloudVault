//
//  AssetPreview.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 10.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI

struct AssetPreview: View {
    
    enum AlertType {
        case none
        case confirmMove
        case confirmRemove
    }
    
    let package: AssetPackage
    @State private var showSheet = false
    @State private var showAlert = false
    @State private var alertType: AlertType = AlertType.none
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        contentView
            .navigationBarItems(trailing: Button(action: { self.showSheet = true }) { Image(systemName: "table.badge.more.fill").imageScale(.large) } )
            .actionSheet(isPresented: $showSheet) {
                ActionSheet(title: Text(AppLocalizationKey.actionSheetTitle.localized), buttons: [
                    .default(Text(AppLocalizationKey.actionMove.localized), action: { self.alertType = .confirmMove; self.showAlert = true } ),
                    .destructive(Text(AppLocalizationKey.actionRemove.localized), action: { self.alertType = .confirmRemove; self.showAlert = true } ),
                    .cancel()])
            }.alert(isPresented: self.$showAlert) {
                
                let confirmation = NSLocalizedString(self.translationKey, comment: "")
                return Alert(title: Text(confirmation), primaryButton: Alert.Button.default(Text("OK"), action: {
                    
                    switch self.alertType {
                    case .confirmMove: if AppRepository.shared.movePackageToDataFolder(package: self.package) { self.presentationMode.wrappedValue.dismiss() }
                    case .confirmRemove: if AppRepository.shared.removePackage(package: self.package) { self.presentationMode.wrappedValue.dismiss() }
                    default: return
                    }
                    
                }), secondaryButton: .cancel())
                
            }

    }
    
    var contentView: some View {
    
        switch package.asset.type {
        case .image:

            guard let uiImage = UIImage(data: package.asset.data) else { return Text("Preview").eraseToAnyView() }
            let imageView = Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fit)
            return imageView.eraseToAnyView()

        case .pdf:
            
            let pdfView = PDFKitView(package.asset.data)
            return pdfView.eraseToAnyView()
            
        default:
            return Text("Preview").eraseToAnyView()
        }
        
    }
    
    var translationKey: String {
        
        switch self.alertType {
        case .confirmMove: return AppLocalizationKey.moveConfirmation.localized
        case .confirmRemove: return AppLocalizationKey.removeConfirmation.localized
        default: return AppLocalizationKey.genericConfirmation.localized
        }
        
    }
    
}
//
//struct AssetPreview_Previews: PreviewProvider {
//    static var previews: some View {
//        AssetPreview()
//    }
//}
