//
//  AppLocalization.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 31.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
enum UserInterfaceLabel: String {

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
    
    var localized: String {
        
        switch self {
        case .inboxTitle: return NSLocalizedString(self.rawValue, comment: "")
        case .vaultTitle: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsTitle: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsSecurity: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsSecurityRequireBiometric: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsSecurityClearInboxAfterDays: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsSecurityMaxLocalSizeInMb: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsdisableThumbnails: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsSystemLog: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsSystemLogOperations: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsSystemLogDiagnose: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsSystemLogErrors: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsApplicationData: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsAtionClearInbox: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsActionClearData: return NSLocalizedString(self.rawValue, comment: "")
        case .settingsActionClearLogs: return NSLocalizedString(self.rawValue, comment: "")
        case .actionEncrypt: return NSLocalizedString(self.rawValue, comment: "")
        case .actionSheetTitle: return NSLocalizedString(self.rawValue, comment: "")
        case .actionMove: return NSLocalizedString(self.rawValue, comment: "")
        case .actionRemove: return NSLocalizedString(self.rawValue, comment: "")
        case .moveConfirmation: return NSLocalizedString(self.rawValue, comment: "")
        case .removeConfirmation: return NSLocalizedString(self.rawValue, comment: "")
        case .genericConfirmation: return NSLocalizedString(self.rawValue, comment: "")
        case .actionSuccess: return NSLocalizedString(self.rawValue, comment: "")
        }
        
    }
    
}
