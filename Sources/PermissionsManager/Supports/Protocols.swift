//
//  Permissions Manager Protocols
//  
//
//  Created by Roberto D’Angelo on 01/01/23.
//

import Foundation
import Combine

public protocol PermissionManagerProtocol: Equatable {
    // the name of the permission
    var icons: PermissionIcons { get set}
    var messages: PermissionMessages { get set}
    var identifier: PermissionIdentifier { get set}
    var authStatus: AuthorizationStatus {get set}
    
    // send events when status changes via permissionManagerEventPublisher
    var eventPublisher: PassthroughSubject<any PermissionManagerProtocol, Never> { get }
    func dispatchEvent()
    
    // the main async functionf for asking for authorization
    func requestAuthorization(completion: @escaping (_ status: AuthorizationStatus) -> Void)
    
    // the function that check authorization status
    func checkAuthorization(completion: @escaping (_ status: AuthorizationStatus) -> Void)
    
    // Asynchronous function thar return AuthorizationStatus
    func returnAuthorizationStatus() async -> AuthorizationStatus
}

public protocol PermissionManagerEventsSubscriber {
    var permissionManagerEventSubscriber: AnyCancellable { get }
    func handlePermissionManagerEvent(_ permission: any PermissionManagerProtocol)

//    public var eventSubscriber: AnyCancellable = AnyCancellable {}
    // example to put in the init()
    //    permissionManagerEventSubscriber = eventPublisher
    //    .sink(receiveValue: { permission in
    //    handlePermissionManagerEvent(permission)
    //    mainDebugger.append("event received")
    //    })
}
