//
//  Speech Permissions.swift
//  
//
//  Created by Roberto D’Angelo on 02/01/23.
//

#if os(iOS)
import Foundation
import Combine
import Speech

public class SpeechPermissionManager: PermissionManagerProtocol {
    // MARK: IMPORTANT - Remind to add Privacy - "Speech Recognition Usage Description" row into info.plist file or it will crash
    
    // MARK: - Initialization
    public var identifier: PermissionIdentifier
    public var icons: PermissionIcons = PermissionIcons(mainIcon: "waveform.circle")
    public var messages: PermissionMessages
    
    private let defaultPreferredLanguage: String = "en"
    public let language: String
    
    public let eventPublisher = PermissionsManager.permissionManagerEventPublisher
    
    public var authStatus: AuthorizationStatus = .notDetermined {
        didSet {
            if oldValue != authStatus {
                dispatchEvent()
            }
        }
    }
    
    public init(isMandatory: Bool) {
        identifier = PermissionIdentifier(name: "SpeechRecognitionLocalized".localized(), debugName: "Speech Recognition", appName: permissionsManagerAppName, isMandatory: isMandatory)
        messages = PermissionMessages(description: defaultDescriptionMsg(permissionName: identifier.name), okMessage: defaultOkMsg(), noOkMessage: defaultNoOkMsg(permissionName: identifier.name), recoveryMsg: defaultRecoveryMsg(appName: identifier.appName))
        language = Locale.preferredLanguages.first ?? defaultPreferredLanguage
    }
    
    // MARK: - dispatch events when changes occur
    public func dispatchEvent() {
        eventPublisher.send(self)
    }
    
    // MARK: - Check Authorization Status
    public func checkAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        switch authStatus {
        case .authorized:
            if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: self.language)), recognizer.isAvailable {
                self.authStatus = .authorized
            } else {
                self.authStatus = .notAvailable
            }
        case .denied:
            self.authStatus = .denied
        case .restricted:
            self.authStatus = .custom(customAuth: "Restricted")
        case .notDetermined:
            self.authStatus = .notDetermined
        @unknown default:
            self.authStatus = .unknown
        }
        completion(self.authStatus)
    }
    
    // MARK: - Request Authorization in Asynchronous
    public func returnAuthorizationStatus() async -> AuthorizationStatus {
        do {
            let authStatus = SFSpeechRecognizer.authorizationStatus()
            switch authStatus {
            case .authorized:
                if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: self.language)), recognizer.isAvailable {
                    self.authStatus = .authorized
                } else {
                    self.authStatus = .notAvailable
                }
            case .denied:
                self.authStatus = .denied
            case .restricted:
                self.authStatus = .custom(customAuth: "Restricted")
            case .notDetermined:
                self.authStatus = .notDetermined
            @unknown default:
                self.authStatus = .unknown
            }
            return self.authStatus
        }
    }
    
    // MARK: - Request Authorization
    public func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: self.language)), recognizer.isAvailable {
                    self.authStatus = .authorized
                } else {
                    self.authStatus = .authorized
                }
            case .denied:
                self.authStatus = .denied
            case .restricted:
                self.authStatus = .custom(customAuth: "Restricted")
            case .notDetermined:
                self.authStatus = .notDetermined
            @unknown default:
                self.authStatus = .unknown
            }
            completion(self.authStatus)
        }
    }
    
    // MARK: - secure class it is equatable
    public static func == (lhs: SpeechPermissionManager, rhs: SpeechPermissionManager) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
#endif

