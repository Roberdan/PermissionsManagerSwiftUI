//
//  UserNotifications Permissions Handling
//  
//
//  Created by Roberto D’Angelo on 01/01/23.
//

import Foundation
import UserNotifications
import Combine

public class NotificationPermissionManager: PermissionManagerProtocol {
    
    // MARK: - Initialization
    public var identifier: PermissionIdentifier
    public var icons: PermissionIcons = PermissionIcons(mainIcon: "bell.circle", deniedIcon: "bell.slash.circle")
    public var messages: PermissionMessages
    
    private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    private var notificationOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
    
    public let eventPublisher = PermissionsManager.permissionManagerEventPublisher
    
    public var authStatus: AuthorizationStatus = .notDetermined {
        didSet {
            if oldValue != authStatus {
                dispatchEvent()
            }
        }
    }
    
    public init(isMandatory: Bool) {
        identifier = PermissionIdentifier(name: "NotificationsLocalized".localized(), debugName: "Notifications", appName: permissionsManagerAppName, isMandatory: isMandatory)
        messages = PermissionMessages(description: defaultDescriptionMsg(permissionName: identifier.name), okMessage: defaultOkMsg(), noOkMessage: defaultNoOkMsg(permissionName: identifier.name), recoveryMsg: defaultRecoveryMsg(appName: identifier.appName))
    }
    
    // MARK: - dispatch events when changes occur
    public func dispatchEvent() {
        eventPublisher.send(self)
    }
    
    // MARK: - Check Authorization Status
    public func checkAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { [self] unNotificationSetting in
            switch unNotificationSetting.authorizationStatus {
            case .notDetermined:
                authStatus = .notDetermined
            case .denied:
                authStatus = .denied
            case .authorized:
                authStatus = .authorized
            case .provisional:
                authStatus = .custom(customAuth: "provisional")
            case .ephemeral:
                authStatus = .custom(customAuth: "ephemeral")
            @unknown default:
                authStatus = .unknown
            }
            completion(authStatus)
        }
    }
    
    // MARK: - Request Authorization in Asynchronous
    public func returnAuthorizationStatus() async -> AuthorizationStatus {
        do {
            let unNotificationSetting = await notificationCenter.notificationSettings()
            switch unNotificationSetting.authorizationStatus {
            case .notDetermined:
                authStatus = .notDetermined
            case .denied:
                authStatus = .denied
            case .authorized:
                authStatus = .authorized
            case .provisional:
                authStatus = .custom(customAuth: "provisional")
            case .ephemeral:
                authStatus = .custom(customAuth: "ephemeral")
            @unknown default:
                authStatus = .unknown
            }
            return authStatus
        }
    }
    
    // MARK: - Request Authorization with Completion
    public func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        notificationCenter.requestAuthorization(options: notificationOptions) { [self] granted, error in
            if let error = error {
                debugPrint("Error in Notification Permissions Manager - Request authorization: \(error.localizedDescription)")
                authStatus = .error(error: error)
            } else {
                if granted {
                    authStatus = .authorized
                } else {
                    authStatus = .denied
                }
            }
            completion(authStatus)
        }
    }
    
    // MARK: - secure class it is equatable
    public static func == (lhs: NotificationPermissionManager, rhs: NotificationPermissionManager) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
