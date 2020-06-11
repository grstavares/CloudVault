//
//  ContentView.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 28.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI

struct RootView: View {
   
    let inboxTitle = AppLocalizationKey.inboxTitle.localized
    let vaultTitle = AppLocalizationKey.vaultTitle.localized
    
    @EnvironmentObject var data: AppRepository
    
    var body: some View {

        TabView {
            FileList(title: inboxTitle, files: data.inbox)
                .tabItem {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text(AppLocalizationKey.inboxTitle.localized)
                }
            FileList(title: vaultTitle, files: data.assets)
                .tabItem {
                    Image(systemName: "lock.fill")
                    Text(AppLocalizationKey.vaultTitle.localized)
                }
            Settings()
                .tabItem {
                    Image(systemName: "gear")
                    Text(AppLocalizationKey.settingsTitle.localized)
                }
        }
        .font(.headline)
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
