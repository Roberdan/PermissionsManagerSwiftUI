//
//  Permissions Manager Constants.swift
//  
//
//  Created by Roberto D’Angelo on 02/01/23.
//

import Foundation

internal var defaultAppName4PermissionsManager: String = "ThisAppNameString".localized()

internal var defaultSupportEmail = "helpme@mirrorhr.org"
internal var permissionsManagerAppName: String = defaultAppName4PermissionsManager

internal func defaultRecoveryMsg(appName: String) -> String {
    return "RecoveryMsgLocalizePart1".localized() + " \(appName) " + "RecoveryMsgLocalizePart2".localized()
}

internal func defaultDescriptionMsg(permissionName: String) -> String {
    return "DescriptionMsgPart1".localized() + " \(permissionName) " + "DescriptionMsgPart2".localized()
}

internal func defaultNoOkMsg(permissionName: String) -> String {
    return "NoOkMessagePart1".localized() + " \(permissionName), " + "NoOkMessagePart2".localized()
}

internal func defaultOkMsg() -> String {
    return "OKMessageLocalized".localized()
}


