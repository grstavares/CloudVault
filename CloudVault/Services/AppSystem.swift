//
//  AppOperation.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 30.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import Combine

class AppSystem: ObservableObject {
    
    public static var shared = AppSystem()

    private var _encoder: JSONEncoder?
    private var _decoder: JSONDecoder?
    private var _isoFormatter: Formatter?
    
    private let serialQueue = DispatchQueue(label: "PublisherQueue", qos: .userInteractive)
    
    @Published private(set) var operations: String = ""
    @Published private(set) var diagnoses: String = ""
    @Published private(set) var exceptions: Error? = nil
    
    private init() { }

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
    
    public func logOperation(message: String, file: String? = nil, line: Int = 0) -> Void {
        let parsedMessage = self.parseMessage(message: message, file: file, line: line)
        serialQueue.sync { self.operations = parsedMessage }
        
    }
    
    public func logDiagnose(message: String, file: String? = nil, line: Int = 0) -> Void {
        let parsedMessage = self.parseMessage(message: message, file: file, line: line)
        serialQueue.sync { self.diagnoses = parsedMessage }
    }
    
    public func logException(error: Error?, file: String? = nil, line: Int = 0) -> Void {
        let parsedMessage = self.parseMessage(error: error, file: file, line: line)
        serialQueue.sync { self.diagnoses = parsedMessage }
    }

    private func parseMessage(error: Error?, file: String?, line: Int) -> String {
        
        let date = AppSystem.shared.isoFormatter.string(for: Date()) ?? "NoDate"
        let message = error?.localizedDescription ?? LOG_MESSAGE_ERROR_NOT_IDENTIFIABLE
        if let filename = file, let fileUrl = URL(string: filename) {
            return "\(date): \(message) file: \(fileUrl.lastPathComponent); line: \(line)"
        } else { return "\(date): \(message)" }
        
    }
    
    private func parseMessage(message: String, file: String?, line: Int) -> String {
        
        let date = AppSystem.shared.isoFormatter.string(for: Date()) ?? "NoDate"
        if let filename = file, let fileUrl = URL(string: filename) {
            return "\(date): \(message) file: \(fileUrl.lastPathComponent); line: \(line)"
        } else { return "\(date): \(message)" }
        
    }
    
    public func releaseResources() -> Void {
        self._encoder = nil
        self._decoder = nil
        self._isoFormatter = nil
        self.operations = "Initialized"
        self.exceptions = nil
    }
    
}

fileprivate let LOG_MESSAGE_ERROR_NOT_IDENTIFIABLE = "Error Not Identifiable!"
