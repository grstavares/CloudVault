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
fileprivate let defaultClearInboxAfterDays = 10
fileprivate let defaulmaxLocalSizeInMb: Double = 200

class AppSettings: ObservableObject {

    private enum Keys: String, CaseIterable {
        case requireBiometric
        case maxLocalSizeInMb
        case clearInboxAfterDays
    }

    private static func defaultValue(for key: Keys) -> AnyHashable {
        
        switch key {
        case .requireBiometric: return defaultBiometric
        case .maxLocalSizeInMb: return defaulmaxLocalSizeInMb
        case .clearInboxAfterDays: return defaultClearInboxAfterDays
        }
        
    }
    
    private let cancellable: Cancellable
    private let defaults: UserDefaults

    let objectWillChange = PassthroughSubject<Void, Never>()
    
    init(defaults: UserDefaults = .standard) {
        
        var defaultValues: [String: AnyHashable] = [:]
        Keys.allCases.forEach { defaultValues[$0.rawValue] = AppSettings.defaultValue(for: $0) }

        defaults.register(defaults: defaultValues)
        self.defaults = defaults
        
        self.cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)
        
    }
    
    var requireBiometric: Bool {
        get { self.defaults.bool(forKey: Keys.requireBiometric.rawValue) }
        set { self.defaults.set(newValue, forKey: Keys.requireBiometric.rawValue) }
    }

    var clearInboxAfterDays: Int {
        get { self.defaults.integer(forKey: Keys.clearInboxAfterDays.rawValue) }
        set { self.defaults.set(newValue, forKey: Keys.clearInboxAfterDays.rawValue) }
    }
    
    var maxLocalSizeInMb: Int {
        get { self.defaults.integer(forKey: Keys.maxLocalSizeInMb.rawValue) }
        set { self.defaults.set(newValue, forKey: Keys.maxLocalSizeInMb.rawValue) }
    }
       
    var keys: [String] { return Keys.allCases.map { $0.rawValue} }
    
    func clearInboxData() -> Bool { return AppRepository.shared.clearInboxFolder() }
    
    func clearVaultData() -> Bool { return AppRepository.shared.clearDataFolder() }
    
    func clearLogData() -> Bool { return AppRepository.shared.clearSystemFolder() }

}
