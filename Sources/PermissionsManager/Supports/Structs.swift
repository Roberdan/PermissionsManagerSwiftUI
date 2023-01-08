//
//  Supporting Structs.swift
//  
//
//  Created by Roberto D’Angelo on 04/01/23.
//

import Foundation

public struct PermissionStatus: Identifiable {
    public var permission: any PermissionManagerProtocol
    public var status: AuthorizationStatus
    public var id: UUID = UUID()
}

public struct PermissionIcons: Equatable {
    var mainIcon: String = "checkmark.circle"
    var deniedIcon: String = "xmark.circle"
    var undeterminedIcon: String = "questionmark.circle"
    var errorIcon: String = "exclamationmark.circle"
}

public struct PermissionMessages: Equatable {
    var description: String
    var okMessage: String
    var noOkMessage: String
    var recoveryMsg: String
}

public struct PermissionIdentifier: Equatable {
    var name: String
    var debugName: String
    var appName: String
    var isMandatory: Bool
    var id: UUID = UUID()
}
