//
//  AppSystem+Log.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 18.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import Combine

public class AppLogger: ObservableObject {
    
    private var serialQueue: DispatchQueue
    
    @Published private(set) var operation: String = ""
    @Published private(set) var diagnose: String = ""
    
    init(context: String) {
        self.serialQueue =  DispatchQueue(label: "\(context).logpublish")
    }
    
    public func logOperation(message: String, file: String? = nil, line: Int = 0) -> Void {
        let parsedMessage = self.parseMessage(message: message, file: file, line: line)
        serialQueue.sync { print(parsedMessage); self.operation = parsedMessage }
    }
    
    public func logDiagnose(message: String, file: String? = nil, line: Int = 0) -> Void {
        let parsedMessage = self.parseMessage(message: message, file: file, line: line)
        serialQueue.sync { self.diagnose = parsedMessage }
    }
    
    public func logException(error: Error?, file: String? = nil, line: Int = 0) -> Void {
        let parsedMessage = self.parseMessage(error: error, file: file, line: line)
        serialQueue.sync { self.diagnose = parsedMessage }
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
    
}

fileprivate let LOG_MESSAGE_ERROR_NOT_IDENTIFIABLE = "Error Not Identifiable!"
