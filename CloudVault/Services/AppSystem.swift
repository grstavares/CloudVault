//
//  AppOperation.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 30.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import Combine

public class AppSystem: ObservableObject {
    
    private static var _shared: AppSystem?
    
    public static var shared:AppSystem {
        
        if AppSystem._shared == nil { AppSystem._shared = AppSystem() }
        return AppSystem._shared!
        
    }

    private var _encoder: JSONEncoder?
    private var _decoder: JSONDecoder?
    private var _isoFormatter: Formatter?
    
    public let bundleName: String
    private let logger: AppLogger
    
    private init() {
        self.bundleName = Bundle.main.bundleIdentifier ?? "notIdentified"
        self.logger = AppLogger(context: self.bundleName)
    }

    @Published var isPortrait: Bool = true
    
    public var encoder: JSONEncoder {
              
      if self._encoder != nil { return self._encoder! }
      
      let newInstance = JSONEncoder()
      self._encoder = newInstance
      return newInstance

   }
    
    public var decoder: JSONDecoder {
           
       if self._decoder != nil { return self._decoder! }
       
       let newInstance = JSONDecoder()
       self._decoder = newInstance
       return newInstance

    }
    
    public var isoFormatter: Formatter {
        
        if self._isoFormatter != nil { return self._isoFormatter! }
        
        let newInstance = ISO8601DateFormatter()
        self._isoFormatter = newInstance
        return newInstance

    }
    
    public func releaseResources() -> Void {
        self._encoder = nil
        self._decoder = nil
        self._isoFormatter = nil
    }
    
}

// Log Methods delegation process
extension AppSystem {
    
    public func logOperation(message: String, file: String? = nil, line: Int = 0) -> Void { self.logger.logOperation(message: message, file: file, line: line) }
    
    public func logDiagnose(message: String, file: String? = nil, line: Int = 0) -> Void { self.logger.logDiagnose(message: message, file: file, line: line) }
    
    public func logException(error: Error?, file: String? = nil, line: Int = 0) -> Void { self.logger.logException(error: error, file: file, line: line) }

}
