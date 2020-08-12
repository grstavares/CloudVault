//
//  AppSettings.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 01.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import Combine

fileprivate let defaultBiometric = false
fileprivate let defaulmaxLocalSizeInMb: Double = 200

class AppSettings: ObservableObject {

    private enum Keys: String, CaseIterable {
        case requireBiometric
        case maxLocalSizeInMb
    }

    private static var _shared: AppSettings?
    
    public static var shared:AppSettings {
        
        if AppSettings._shared == nil { AppSettings._shared = AppSettings() }
        return AppSettings._shared!
        
    }
    
    private static func defaultValue(for key: Keys) -> AnyHashable {
        
        switch key {
        case .requireBiometric: return defaultBiometric
        case .maxLocalSizeInMb: return defaulmaxLocalSizeInMb
        }
        
    }
    
    private let defaults: UserDefaults

    @Published var requireBiometric: Bool {
        didSet { self.defaults.set(requireBiometric, forKey: Keys.requireBiometric.rawValue) }
    }
    
    @Published var maxLocalSizeInMb: Int {
        didSet { self.defaults.set(maxLocalSizeInMb, forKey: Keys.maxLocalSizeInMb.rawValue) }
    }
    
    private init(defaults: UserDefaults = .standard) {
        
        var defaultValues: [String: AnyHashable] = [:]
        Keys.allCases.forEach { defaultValues[$0.rawValue] = AppSettings.defaultValue(for: $0) }

        defaults.register(defaults: defaultValues)

        self.defaults = defaults
        self.requireBiometric =  self.defaults.bool(forKey: Keys.requireBiometric.rawValue)
        self.maxLocalSizeInMb = self.defaults.integer(forKey: Keys.maxLocalSizeInMb.rawValue)

    }
    
    private func reloadValues() -> Void {
        self.requireBiometric =  self.defaults.bool(forKey: Keys.requireBiometric.rawValue)
        self.maxLocalSizeInMb = self.defaults.integer(forKey: Keys.maxLocalSizeInMb.rawValue)
    }
       
    var keys: [String] { return Keys.allCases.map { $0.rawValue} }
    
    func clearInboxData() -> Bool { return AppRepository.shared.clearInboxFolder() }
    
    func clearVaultData() -> Bool { return AppRepository.shared.clearDataFolder() }
    
    func clearLogData() -> Bool { return AppRepository.shared.clearSystemFolder() }

}
