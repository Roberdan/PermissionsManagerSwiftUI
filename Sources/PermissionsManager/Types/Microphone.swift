//
//  Microphone Permissions Manager.swift
//  
//
//  Created by Roberto D’Angelo on 02/01/23.
//

#if os(iOS)
import Foundation
import Combine

import AVFoundation

public class MicrophonePermissionManager: PermissionManagerProtocol {
    
    // MARK: IMPORTANT - Remind to add Privacy - "Privacy - Microphone Usage Description" row into info.plist file or it will crash
    
    // MARK: - Initialization
    public var identifier: PermissionIdentifier
    public var icons: PermissionIcons = PermissionIcons(mainIcon: "mic.circle", deniedIcon: "mic.slash.circle")
    public var messages: PermissionMessages
    
    public let eventPublisher = PermissionsManager.permissionManagerEventPublisher
    
    public var authStatus: AuthorizationStatus = .notDetermined {
        didSet {
            if oldValue != authStatus {
                dispatchEvent()
            }
        }
    }
    public init(isMandatory: Bool) {
        identifier = PermissionIdentifier(name: "MicrophoneLocalized".localized(), debugName: "Microphone", appName: permissionsManagerAppName, isMandatory: isMandatory)
        messages = PermissionMessages(description: defaultDescriptionMsg(permissionName: identifier.name), okMessage: defaultOkMsg(), noOkMessage: defaultNoOkMsg(permissionName: identifier.name), recoveryMsg: defaultRecoveryMsg(appName: identifier.appName))
    }
    
    // MARK: - dispatch events when changes occur
    public func dispatchEvent() {
        eventPublisher.send(self)
    }
    
    // MARK: - Check Authorization Status
    public func checkAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .audio){
        case .authorized:
            authStatus = .authorized
        case .notDetermined:
            authStatus = .notDetermined
        case .restricted:
            authStatus = .custom(customAuth: "Restricted")
        case .denied:
            authStatus = .denied
        @unknown default:
            authStatus = .unknown
        }
        completion(authStatus)
    }
    
    
    // MARK: - Request Authorization in Asynchronous
    public func returnAuthorizationStatus() async -> AuthorizationStatus {
        do {
            switch AVCaptureDevice.authorizationStatus(for: .audio){
            case .authorized:
                authStatus = .authorized
            case .notDetermined:
                authStatus = .notDetermined
            case .restricted:
                authStatus = .custom(customAuth: "Restricted")
            case .denied:
                authStatus = .denied
            @unknown default:
                authStatus = .unknown
            }
            return authStatus
        }
    }
    
    // MARK: - Request Authorization
    public func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { [self] granted in
            if granted {
                authStatus = .authorized
            } else {
                authStatus = .denied
            }
            completion(authStatus)
        }
    }
    
    // MARK: - secure class it is equatable
    public static func == (lhs: MicrophonePermissionManager, rhs: MicrophonePermissionManager) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
#endif
