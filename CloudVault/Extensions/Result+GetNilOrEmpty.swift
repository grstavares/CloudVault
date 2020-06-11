//
//  Result+GetNilOrEmpty.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 08.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
extension Result where Success: Collection {
    
    public func getValidValues<T>() -> [T] {
    
        guard let values = try? self.get() else {
            return []
        }

        return values.compactMap { $0 as? T }
        
    }
    
}
