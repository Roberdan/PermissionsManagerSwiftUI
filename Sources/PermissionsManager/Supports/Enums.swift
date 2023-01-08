//
//  PermissionsManager Enums.swift
//  
//
//  Created by Roberto D’Angelo on 21/12/22.
//

import Foundation

// All types of permissions that are handled by Permissions Manager
public enum PermissionType: CaseIterable {
    case notification
    case criticalAlert
    case health
    case speech
    case microphone
    case camera
    case photoLibrary
}

public enum AuthorizationStatus: Equatable {
    case notDetermined
    case denied
    case authorized
    case custom(customAuth: String)
    case unknown
    case error(error: Error)
    case notAvailable
    
    public var localizedDescription: String {
        switch self {
        case .notDetermined:
            return "NotDeterminedLocalized".localized()
        case .denied:
            return "DeniedLocalized".localized()
        case .authorized:
            return "AuthorizedLocalized".localized()
        case .unknown:
            return "UnknownLocalized".localized()
        case .custom(customAuth: let customAuth):
            return "\(customAuth)".localized()
        case .error(error: let error):
            return "\(error.localizedDescription)"
        case .notAvailable:
            return "NotAvailableLocalized".localized()
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .notDetermined:
            return "NotDetermined"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .unknown:
            return "Unknown"
        case .custom(customAuth: let customAuth):
            return "\(customAuth)"
        case .error(error: let error):
            return "\(error)"
        case .notAvailable:
            return "NotAvailable"
        }
    }
    
    public var isAuthorized: Bool {
        switch self {
        case .notDetermined, .denied, .custom, .unknown, .error, .notAvailable:
            return false
        case .authorized:
            return true
        }
    }
    
    public var isNotAuthorized: Bool {
        switch self {
        case .notDetermined, .denied, .custom, .unknown, .error, .notAvailable:
            return true
        case .authorized:
            return false
        }
    }
    
    public var isNotCheckeYet: Bool {
        switch self {
        case .notDetermined:
            return true
        case .authorized, .denied, .custom, .unknown, .error, .notAvailable:
            return false
        }
    }
    
    public var itHasBeenChecked: Bool {
        switch self {
        case .notDetermined:
            return false
        case .authorized, .denied, .custom, .unknown, .error, .notAvailable:
            return true
        }
    }
    
    private var value: String? {
        return String(describing: self).components(separatedBy: "(").first
    }
    
    public static func == (lhs: AuthorizationStatus, rhs: AuthorizationStatus) -> Bool {
        lhs.value == rhs.value
    }
}

// Errors for Permissions Manager
enum PermissionsErrors {
    case permissionTypeNotExist
    
    public var description: String {
        switch self {
        case .permissionTypeNotExist:
            return "PermissionsManagerErrorTypeDoesNotExistLocalized"
        }
    }
    
    public var error: Error {
        switch self {
        case .permissionTypeNotExist:
            return NSError(domain: "Permissions Manager", code: 101, userInfo: [NSLocalizedDescriptionKey: self.description.debugDescription])
        }
    }
}
