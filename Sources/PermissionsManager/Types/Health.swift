//
//  Health Permissions.swift
//  
//
//  Created by Roberto D’Angelo on 02/01/23.
//

import Foundation
import Combine

import HealthKit

public class HealthPermissionManager: PermissionManagerProtocol {
    // MARK: IMPORTANT - Remind to add Privacy - "NSHealthUpdateUsageDescription" row into info.plist file or it will crash - "Enabling Access to Health data is essential for this app to work properly."
    
    // MARK: - Initialization
    public var identifier: PermissionIdentifier
    public var icons: PermissionIcons = PermissionIcons(mainIcon: "heart.circle", deniedIcon: "heart.slash.circle")
    public var messages: PermissionMessages

    public let eventPublisher = PermissionsManager.permissionManagerEventPublisher
    
    public var authStatus: AuthorizationStatus = .notDetermined {
        didSet {
            if oldValue != authStatus {
                dispatchEvent()
            }
        }
    }
    
    // health specifics
    private let healthStore = HKHealthStore()
    private let heartRateIdentifier: HKQuantityTypeIdentifier = .heartRate
    private let oxygenSaturationIdentifier: HKQuantityTypeIdentifier = .oxygenSaturation
    private let hrvIdentifier: HKQuantityTypeIdentifier = .heartRateVariabilitySDNN
    private let respiratoryRateIdentifier: HKQuantityTypeIdentifier = .respiratoryRate
    private let sleepIdentifier: HKCategoryTypeIdentifier = .sleepAnalysis
    private let workOut: HKWorkoutType = HKObjectType.workoutType()
    private var heartRate: HKQuantityType?
    private var oxygenSaturation: HKQuantityType?
    private var hrv: HKQuantityType?
    private var respiratoryRate: HKQuantityType?
    private var sleep: HKCategoryType?
    
    // MARK: - Init
    public init(isMandatory: Bool) {
        identifier = PermissionIdentifier(name: "HealthDataLocalized".localized(), debugName: "Health Data", appName: permissionsManagerAppName, isMandatory: isMandatory)
        messages = PermissionMessages(description: defaultDescriptionMsg(permissionName: identifier.name), okMessage: defaultOkMsg(), noOkMessage: defaultNoOkMsg(permissionName: identifier.name), recoveryMsg: defaultRecoveryMsg(appName: identifier.appName))
    }
    
    // MARK: - dispatch events when changes occur
    public func dispatchEvent() {
        eventPublisher.send(self)
    }
    
    // MARK: - Check Authorization Status
    public func checkAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        authStatus = healthStoreAuthorizationStatus()
        completion (authStatus)
    }
    
    
    // MARK: - Request Authorization in Asynchronous
    public func returnAuthorizationStatus() async -> AuthorizationStatus {
        do {
            authStatus = healthStoreAuthorizationStatus()
            return authStatus
        }
    }
    
    // MARK: - Request Authorization
    public func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() == true,
              let heartRate = HKObjectType.quantityType(forIdentifier: heartRateIdentifier),
              let oxygenSaturation = HKObjectType.quantityType(forIdentifier: oxygenSaturationIdentifier),
              let hrv = HKObjectType.quantityType(forIdentifier: hrvIdentifier),
              let respiratoryRate = HKObjectType.quantityType(forIdentifier: respiratoryRateIdentifier),
              let sleep = HKObjectType.categoryType(forIdentifier: sleepIdentifier)
        else {
            authStatus = .notAvailable
            completion(authStatus)
            return
        }
        
        let typesToWrite: Set<HKSampleType> = [heartRate,
                                               oxygenSaturation,
                                               hrv,
                                               sleep,
                                               respiratoryRate,
                                               workOut]
        
        let typesToRead: Set<HKObjectType> = [heartRate,
                                              oxygenSaturation,
                                              hrv,
                                              sleep,
                                              respiratoryRate,
                                              workOut]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [self] userWasShownPermissionView, error in
            if let error = error {
                debugPrint("Error in HealthPermissionManager: \(error.localizedDescription)")
                authStatus = .error(error: error)
                completion(authStatus)
                return
            }
            if (userWasShownPermissionView) {
                authStatus = self.healthStoreAuthorizationStatus()
            } else {
                // User was not shown permission view
                authStatus = .denied
            }
            completion (authStatus)
        }
    }
    
    // MARK: - secure class it is equatable
    public static func == (lhs: HealthPermissionManager, rhs: HealthPermissionManager) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    private func healthStoreAuthorizationStatus()  -> AuthorizationStatus {
        guard HKHealthStore.isHealthDataAvailable() == true,
              let heartRate = HKObjectType.quantityType(forIdentifier: heartRateIdentifier),
              let oxygenSaturation = HKObjectType.quantityType(forIdentifier: oxygenSaturationIdentifier),
              let hrv = HKObjectType.quantityType(forIdentifier: hrvIdentifier),
              let respiratoryRate = HKObjectType.quantityType(forIdentifier: respiratoryRateIdentifier),
              let sleep = HKObjectType.categoryType(forIdentifier: sleepIdentifier)
        else {
            return .notAvailable
        }
        
        if self.healthStore.authorizationStatus(for: heartRate) == .sharingAuthorized,
           self.healthStore.authorizationStatus(for: oxygenSaturation) == .sharingAuthorized,
           self.healthStore.authorizationStatus(for: hrv) == .sharingAuthorized,
           self.healthStore.authorizationStatus(for: respiratoryRate) == .sharingAuthorized,
           self.healthStore.authorizationStatus(for: sleep) == .sharingAuthorized {
            return .authorized
        } else {
            if self.healthStore.authorizationStatus(for: heartRate) == .notDetermined,
               self.healthStore.authorizationStatus(for: oxygenSaturation) == .notDetermined,
               self.healthStore.authorizationStatus(for: hrv) == .notDetermined,
               self.healthStore.authorizationStatus(for: respiratoryRate) == .notDetermined,
               self.healthStore.authorizationStatus(for: sleep) == .notDetermined {
                return .notDetermined
            } else {
                return .denied
            }
        }
    }
}
