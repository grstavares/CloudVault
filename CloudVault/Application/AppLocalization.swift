//
//  AppLocalization.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 31.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
enum AppLocalizationKey: String {
    case inboxTitle
    case vaultTitle
    case settingsTitle
    case settingsSecurity
    case settingsSecurityRequireBiometric
    case settingsSecurityClearInboxAfterDays
    case settingsSecurityMaxLocalSizeInMb
    case settingsdisableThumbnails
    case settingsSystemLog
    case settingsSystemLogOperations
    case settingsSystemLogDiagnose
    case settingsSystemLogErrors
    case settingsApplicationData
    case settingsAtionClearInbox
    case settingsActionClearData
    case settingsActionClearLogs
    case actionEncrypt
    case actionSheetTitle
    case actionMove
    case actionRemove
    case moveConfirmation
    case removeConfirmation
    case genericConfirmation
    case actionSuccess
    
    var localized: String { NSLocalizedString(self.rawValue, comment: "") }
    
}
