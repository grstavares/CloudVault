//
//  File.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 30.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

fileprivate let SYS_LOG_PREFIX = "operations"
fileprivate let SYS_DIAGNOSE_PREFIX = "diagnose"
fileprivate let SYS_ERROR_PREFIX = "errors"

import Foundation
extension AppSystem {
    
    static let appGroupId: String? = "group.br.com.brclouders.CloudVault"

    public var sysLogFileName: String {
        
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let filename = "\(year)-\(String(format: "%02d", month))_\(SYS_LOG_PREFIX).log"
        return filename
        
    }

    public var sysDiagnoseFileName: String {
        
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let filename = "\(year)-\(String(format: "%02d", month))_\(SYS_DIAGNOSE_PREFIX).log"
        return filename
        
    }

    public var sysErrorFileName: String {
        
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let filename = "\(year)-\(String(format: "%02d", month))_\(SYS_ERROR_PREFIX).log"
        return filename
        
    }
    
}
