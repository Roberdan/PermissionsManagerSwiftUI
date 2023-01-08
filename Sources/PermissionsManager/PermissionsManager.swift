//
//  Permissions Manager
//
//
//  Created by Roberto D’Angelo on 01/01/23.
//

import SwiftUI
import Combine

public class PermissionsManager: ObservableObject, PermissionManagerEventsSubscriber {
    public var permissionManagerEventSubscriber: AnyCancellable = AnyCancellable {}
    public static let permissionManagerEventPublisher = PassthroughSubject<any PermissionManagerProtocol, Never>()
    public static var shared: PermissionsManager = PermissionsManager()
    
    internal var appName: String
    internal var supportEmail: String
    internal var standBy: Bool
    @Published internal var grantedPermissions: [any PermissionManagerProtocol] = []
    @Published internal var deniedPermissions: [any PermissionManagerProtocol] = []
    @Published internal var notCheckedYetPermissions: [any PermissionManagerProtocol] = []
    @Published internal var allGranted: Bool = false
    @Published internal var allMandatoryGranted: Bool = false
    @Published internal var permissionsStatus: [PermissionStatus] = []
    @Published internal var skipped: Bool = false {
        didSet {
            refresh()
        }
    }
    @Published public var canGoAhead: Bool
    
    internal let group = DispatchGroup()
    private var permissionsInternal: [any PermissionManagerProtocol] = [any PermissionManagerProtocol]()
    
    public func personalize(appName: String,
                            supportEmail: String,
                            permissionsToHandle: [PermissionType]) {
        Task {
            self.appName = appName
            self.supportEmail = supportEmail
            permissionsManagerAppName = appName
            permissionsInternal = []
            for permissionType in permissionsToHandle {
                self.permissionsInternal.append(permissionType.permission)
            }
            for cnt in 0...(permissionsInternal.count - 1) {
                permissionsInternal[cnt].identifier.appName = appName
            }
            self.standBy = false
            await publishUpdatesInternal()
        }
    }
    
    // MARK: - initial internal only init: PermissionsManager has not been personalized yet, so it's in standBy

    internal init() {
        self.appName = defaultAppName4PermissionsManager
        self.supportEmail = defaultSupportEmail
        permissionsManagerAppName = self.appName
        self.permissionsInternal = []
        self.standBy = true
        self.canGoAhead = !self.standBy
        permissionManagerEventSubscriber = PermissionsManager.permissionManagerEventPublisher
            .sink(receiveValue: { [self] permission in
                handlePermissionManagerEvent(permission)
            })
    }
    
}

// MARK: private functions
extension PermissionsManager {
    public func handlePermissionManagerEvent(_ permission: any PermissionManagerProtocol) {
        debugPrint("Event received in Permissions Manager: \(permission.identifier.debugName) - \(permission.authStatus)")
        Task {
            await publishUpdatesInternal()
        }
    }
    
    internal var permissions: [any PermissionManagerProtocol] {
        return Array(permissionsInternal)
    }
    
    internal func refresh() {
        Task {
            await publishUpdatesInternal()
        }
    }
    
    // Update Published var deniedPermissions with all permissions denied, in async way
    private func publishUpdatesInternal() async {
        var grantedInternal: [any PermissionManagerProtocol] = []
        var deniedInternal: [any PermissionManagerProtocol] = []
        var notCheckedInternal: [any PermissionManagerProtocol] = []
        var statusInternal: [PermissionStatus] = []
        
        for permission in permissionsInternal.sorted(by: { lhs, rhs in
            lhs.identifier.name < rhs.identifier.name
        }) {
            group.enter()
            do {
                let status = await permission.returnAuthorizationStatus()
                statusInternal.append(PermissionStatus(permission: permission, status: status, id: UUID()))
                
                if status == .authorized, !grantedInternal.contains(where: { check in
                    check.identifier.name == permission.identifier.name
                }) {
                    grantedInternal.append(permission)
                }
                if status == .notDetermined, !notCheckedInternal.contains(where: { check in
                    check.identifier.name == permission.identifier.name
                }) {
                    notCheckedInternal.append(permission)
                }
                if status == .denied, !deniedInternal.contains(where: { check in
                    check.identifier.name == permission.identifier.name
                }) {
                    deniedInternal.append(permission)
                }
            }
            group.leave()
        }
        // notify the main thread when all task are completed
        group.notify(queue: .main) {
            self.permissionsStatus = statusInternal
            self.grantedPermissions = grantedInternal
            self.deniedPermissions = deniedInternal
            self.notCheckedYetPermissions = notCheckedInternal
            if grantedInternal.count == self.permissionsInternal.count {
                self.allGranted = true
            } else {
                self.allGranted = false
            }
            
            // check mandatory permissions
            let mandatoryPermissions: [any PermissionManagerProtocol] = self.permissionsInternal.filter { permission in
                permission.identifier.isMandatory == true
            }
            var mandatoryCheck: Bool = true
            for mandatoryPermission in mandatoryPermissions {
                if mandatoryPermission.authStatus != .authorized {
                    mandatoryCheck = false
                    break
                }
            }
            self.allMandatoryGranted = mandatoryCheck
            self.canGoAhead = (mandatoryCheck == true && self.skipped) || self.allGranted
        }
    }
    
    // Return an array with all denied permissions
    private func deniedPermissionsStatic() -> [any PermissionManagerProtocol] {
        var deniedPermissions: [any PermissionManagerProtocol] = []
        permissionsInternal.forEach { permission in
            permission.checkAuthorization { status in
                if status.isNotAuthorized, status.itHasBeenChecked {
                    deniedPermissions.append(permission)
                }
            }
        }
        return Array(deniedPermissions)
    }
    
    // Return an array with all granted permissions
    private func grantedPermissionsStatic() -> [any PermissionManagerProtocol] {
        var grantedPermissions: [any PermissionManagerProtocol] = []
        permissionsInternal.forEach { permission in
            permission.checkAuthorization { status in
                if status.isAuthorized {
                    grantedPermissions.append(permission)
                }
            }
        }
        return Array(grantedPermissions)
    }
    
    // Return an array with all permissions not checked yet
    private func notCheckedYetdPermissionsStatic() -> [any PermissionManagerProtocol] {
        var notCheckedYetPermissions: [any PermissionManagerProtocol] = []
        permissionsInternal.forEach { permission in
            permission.checkAuthorization { status in
                if status.isNotCheckeYet {
                    notCheckedYetPermissions.append(permission)
                }
            }
        }
        return Array(notCheckedYetPermissions)
    }
    
    private func addPermission(permission: any PermissionManagerProtocol) {
        permissionsInternal.append(permission)
    }
    
#if os(iOS)
    static public var allPossiblePermissions: [any PermissionManagerProtocol] = [
        NotificationPermissionManager(isMandatory: true),
        CriticalNotificationPermissionManager(isMandatory: true),
        SpeechPermissionManager(isMandatory: false),
        MicrophonePermissionManager(isMandatory: false),
        CameraPermissionManager(isMandatory: false),
        HealthPermissionManager(isMandatory: true)
    ]
#endif
#if os(watchOS)
    static public var allPossiblePermissions: [any PermissionManagerProtocol] = [
        NotificationPermissionManager(isMandatory: true),
        CriticalNotificationPermissionManager(isMandatory: true),
        HealthPermissionManager(isMandatory: true)
    ]
#endif
}

extension PermissionsManager {
#if os(iOS)
    public enum PermissionType: Equatable {
        case notifications(isMandatory: Bool)
        case criticalNotification(isMandatory: Bool)
        case speech(isMandatory: Bool)
        case microphone(isMandatory: Bool)
        case camera(isMandatory: Bool)
        case health(isMandatory: Bool)
        
        public var permission: any PermissionManagerProtocol {
            switch self {
            case .speech(isMandatory: let isMandatory):
                return SpeechPermissionManager(isMandatory: isMandatory)
            case .microphone(isMandatory: let isMandatory):
                return MicrophonePermissionManager(isMandatory: isMandatory)
            case .camera(isMandatory: let isMandatory):
                return CameraPermissionManager(isMandatory: isMandatory)
            case .notifications(isMandatory: let isMandatory):
                return NotificationPermissionManager(isMandatory: isMandatory)
            case .criticalNotification(isMandatory: let isMandatory):
                return CriticalNotificationPermissionManager(isMandatory: isMandatory)
            case .health(isMandatory: let isMandatory):
                return HealthPermissionManager(isMandatory: isMandatory)
            }
        }
    }
#endif
    
#if os(watchOS)
    public enum PermissionType: Equatable {
        case notifications(isMandatory: Bool)
        case criticalNotification(isMandatory: Bool)
        case health(isMandatory: Bool)
        
        public var permission: any PermissionManagerProtocol {
            switch self {
            case .notifications(isMandatory: let isMandatory):
                return NotificationPermissionManager(isMandatory: isMandatory)
            case .criticalNotification(isMandatory: let isMandatory):
                return CriticalNotificationPermissionManager(isMandatory: isMandatory)
            case .health(isMandatory: let isMandatory):
                return HealthPermissionManager(isMandatory: isMandatory)
            }
        }
    }
#endif
    
}
