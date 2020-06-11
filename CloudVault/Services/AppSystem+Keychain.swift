//
//  AppSystem+Keychain.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 08.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import CryptoKit

extension AppSystem {
    
    public static let encriptionContext = "br.com.brclouders.CloudVault"
    public func encriptionKey(for context: String) -> SymmetricKey? { return nil }
    
}
