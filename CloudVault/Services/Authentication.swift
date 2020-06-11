//
//  Authentication.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 28.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
import LocalAuthentication
import Combine

enum AuthenticationError: Error {
    case userCanceledAuthentication
    case biometricAuthenticationNotAvailable
    case biometricAuthenticationFailed
    case notIdentified
}

private enum AuthenticatorStringKey: String {
    case cancelTitle
    case authReason
}

typealias AuthenticationStatus = Result<Bool, AuthenticationError>

class Authenticator {
    
    public static var shared = Authenticator()
    public let status = CurrentValueSubject<AuthenticationStatus, Never>(Result.success(false))
    
    private let blockAuthenticationOnCode = true
    
    private init() { }
    
    public func authenticateWithBiometrics() {
        
        let cancelTitle = NSLocalizedString(AuthenticatorStringKey.cancelTitle.rawValue, comment: "Title to be presented in the Authentication Modal for Cancel the Auth Process")
        let authReason = NSLocalizedString(AuthenticatorStringKey.authReason.rawValue, comment: "Title to be presented in the Authentication Modal")
        
        let context = LAContext()
        
        context.localizedCancelTitle = cancelTitle
        
        var errorPointer: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &errorPointer) else {
            let authError = parseErrorReason(errorPointer)
            self.status.send(Result.failure(authError))
            return
        }
        
        let authPolicy = self.blockAuthenticationOnCode ? LAPolicy.deviceOwnerAuthenticationWithBiometrics : LAPolicy.deviceOwnerAuthentication
        context.evaluatePolicy(authPolicy, localizedReason: authReason ) { success, error in

            if success {
                self.status.send(Result.success(true))
            } else {
                let authError = self.parseErrorReason(error)
                self.status.send(Result.failure(authError))
            }
        }
        
    }

    public func authenticateWithCredentials(username: String, password: String) {
        
    }
    
    private func parseErrorReason(_ error: NSError?) -> AuthenticationError {
        
        if let nonOptional = error {
            
            switch nonOptional.code {
            case LAError.appCancel.rawValue: return .userCanceledAuthentication
            case LAError.biometryLockout.rawValue: return .biometricAuthenticationFailed
            case LAError.biometryNotAvailable.rawValue: return .biometricAuthenticationNotAvailable
            case LAError.biometryNotEnrolled.rawValue: return .biometricAuthenticationNotAvailable
            case LAError.biometryLockout.rawValue: return .biometricAuthenticationFailed
            default: return .notIdentified
            }
            
        } else { return .notIdentified }
               
    }
    
    private func parseErrorReason(_ error: Error?) -> AuthenticationError {
        
        return self.parseErrorReason(error as NSError?)
                
    }
    
    
}
