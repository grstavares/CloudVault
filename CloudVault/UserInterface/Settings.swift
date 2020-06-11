//
//  Settings.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 29.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI

struct Settings: View {

    let logTypes = [
        LogType(title: AppLocalizationKey.settingsSystemLogOperations, filter: "operations"),
        LogType(title: AppLocalizationKey.settingsSystemLogDiagnose, filter: "diagnose"),
        LogType(title: AppLocalizationKey.settingsSystemLogErrors, filter: "errors")
    ]
    
    @EnvironmentObject var settings: AppSettings

    @State var askInboxClearConfirmation = false
    @State var askDataClearConfirmation = false
    @State var askLogClearConfirmation = false
    
    @State private var bannerTitle: String = ""
    @State private var bannerText: String = ""
    @State private var showClearSuccess = false
    
    var body: some View {
        
        NavigationView {
            
            Form {
                
                Section(header: Text(AppLocalizationKey.settingsSecurity.localized)) {
                    Toggle(isOn: $settings.requireBiometric) {
                        Text("\(AppLocalizationKey.settingsSecurityRequireBiometric.localized):")
                    }
                    
                    Stepper(value: $settings.clearInboxAfterDays, in: 0...30) {
                        Text("\(AppLocalizationKey.settingsSecurityClearInboxAfterDays.localized): \(settings.clearInboxAfterDays)")
                    }
                    
                    Stepper(value: $settings.maxLocalSizeInMb, in: 0...1000, step: 50) {
                        Text("\(AppLocalizationKey.settingsSecurityMaxLocalSizeInMb.localized): \(settings.maxLocalSizeInMb)")
                    }
                }
                
                Section(header: Text(AppLocalizationKey.settingsSystemLog.localized)) {
                    
                    List(logTypes) { logType in
                        NavigationLink(destination: LogTypeView(logType: logType)) {
                            Text(logType.title.localized)
                        }
                    }
                    
                }
                
                Section(header: Text(AppLocalizationKey.settingsApplicationData.localized)) {
                    
                    Button(action: { self.askInboxClearConfirmation = true }) {
                        Text(AppLocalizationKey.settingsAtionClearInbox.localized)
                    }.buttonStyle(Danger())
                    .alert(isPresented: $askInboxClearConfirmation) {
                        Alert(
                        title: Text("Important message"),
                        message: Text("Wear sunscreen"),
                        primaryButton: .destructive(Text("OK"), action: {
                            self.bannerTitle = "Success"
                            self.bannerText = "Inbox Cleared"
                            self.showClearSuccess = self.settings.clearInboxData()
                        }), secondaryButton: .cancel())
                    }
                    
                    Button(action: { self.askDataClearConfirmation = true }) {
                        Text(AppLocalizationKey.settingsActionClearData.localized)
                    }.buttonStyle(Danger())
                    .alert(isPresented: $askDataClearConfirmation) {
                        Alert(
                        title: Text("Important message"),
                        message: Text("Wear sunscreen"),
                        primaryButton: .destructive(Text("OK"), action: {
                            self.bannerTitle = "Success"
                            self.bannerText = "Data Folder Cleared"
                            self.showClearSuccess = self.settings.clearVaultData()
                        }), secondaryButton: .cancel())
                    }
                    
                    Button(action: { self.askLogClearConfirmation = true }) {
                        Text(AppLocalizationKey.settingsActionClearLogs.localized)
                    }.buttonStyle(Danger())
                    .alert(isPresented: $askLogClearConfirmation) {
                        Alert(
                        title: Text("Important message"),
                        message: Text("Wear sunscreen"),
                        primaryButton: .destructive(Text("OK"), action: {
                            self.bannerTitle = "Success"
                            self.bannerText = "System Logs Cleared"
                            self.showClearSuccess = self.settings.clearLogData()
                        }), secondaryButton: .cancel())
                    }

                }
                
            }.navigationBarTitle(Text(AppLocalizationKey.settingsTitle.localized))
            .banner(data: Banner.info(title: self.bannerTitle, detail: self.bannerText), show: $showClearSuccess)
        }
    }
}

struct LogTypeView: View {
    
    let logType: LogType
    var files: [RepositoryFile] {
        
        AppRepository.shared
            .getFileListFromSystemFolder()
            .getValidValues()
            .filter { (file: RepositoryFile) in file.url.absoluteString.contains(self.logType.filter) }
        
    }
    
    var body: some View {
        
        List(files) { (file) in
            NavigationLink(destination: LogFileView(file: file)) {
                Text(file.url.lastPathComponent)
            }
        }.navigationBarTitle(AppLocalizationKey.settingsSystemLog.localized)
        
    }
    
}

struct LogFileView: View {
    
    let file: RepositoryFile
    var data: Data { self.file.data ?? "no data".data(using: .utf8)!  }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            Text(String(data: data, encoding: .utf8)!)
                .alignmentGuide(.top, computeValue: { d in d[explicit: .top]! })
                .multilineTextAlignment(.leading)
        }
    }
    
}

struct LogType: Identifiable, Hashable {
    var id: String { self.title.rawValue }
    let title: AppLocalizationKey
    let filter: String
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
