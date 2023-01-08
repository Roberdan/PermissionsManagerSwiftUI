//
//  Test Permissions Manager View.swift
//  
//
//  Created by Roberto D’Angelo on 02/01/23.
//

import SwiftUI

public struct PermissionsManagerSampleView: View {
    let permissionsManager: PermissionsManager = .shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Permissions Manager")
                    .font(.title)
                    .fontWeight(.heavy)
                
                CheckAllGrantedView()
                
                ListNotCheckedPermissions()
                
                ListAllGrantedPermissions()
                
                ListAllDeniedPermissions()
                
                AskPermissionsView(permissionsManager: permissionsManager)
                
                CompletionPermissionsCheckView(permissionsManager: permissionsManager)
                
                AsyncPermissionsManagerView(permissionsManager: permissionsManager)
                
            }
            .padding()
            .multilineTextAlignment(.leading)
        }
    }
}

struct PermissionsManagerSampleView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsManagerSampleView()
    }
}

struct ListAllGrantedPermissions: View {
    @ObservedObject var permissionManager: PermissionsManager = .shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Granted Permissions")
                .font(.title)
            ForEach(permissionManager.grantedPermissions, id: \.identifier.id) { permission in
                Label(permission.identifier.name, systemImage: permission.icons.mainIcon)
                    .foregroundColor(.green)
            }
            Divider()
        }
    }
}

struct ListAllDeniedPermissions: View {
    @ObservedObject var permissionManager: PermissionsManager = .shared

    var body: some View {
        VStack(alignment: .leading) {
            Text("Denied Permissions")
                .font(.title)
            ForEach(permissionManager.deniedPermissions, id: \.identifier.id) { permission in
                Label(permission.identifier.name, systemImage: permission.icons.deniedIcon)
                    .foregroundColor(.red)
            }
            Divider()
        }
    }
}

struct ListNotCheckedPermissions: View {
    @ObservedObject var permissionManager: PermissionsManager = .shared

    var body: some View {
        VStack(alignment: .leading) {
            Text("Not checked yet permissions")
                .font(.title)
            ForEach(permissionManager.notCheckedYetPermissions, id: \.identifier.id) { permission in
                Button {
                    permission.requestAuthorization { status in
                    }
                } label: {
                    Label(permission.identifier.name, systemImage: permission.icons.mainIcon)
                }
            }
            Divider()
        }
    }
}

struct CheckAllGrantedView: View {
    @ObservedObject var permissionManager: PermissionsManager = .shared

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(permissionManager.allGranted ? "all granted" : "NOT all granted")")
            }
            Divider()
        }
    }
}
struct AskPermissionsView: View {
    let permissionsManager: PermissionsManager
    @State var statusMsg: String = "Ready to Ask"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ask Permissions")
                .font(.title)
            
            ForEach(
                permissionsManager.permissions,
                id: \.identifier.id,
                content: { permission in
                    Button {
                        permission.requestAuthorization { status in
                            statusMsg = "Status for \(permission.identifier.name) is: \(status.localizedDescription)"
                        }
                    } label: {
                        Label(permission.identifier.name, systemImage: permission.icons.mainIcon)
                    }
                })
            Text("")
            Text(statusMsg)
                .font(.headline)
            Divider()
        }
    }
}

struct CompletionPermissionsCheckView: View {
    let permissionsManager: PermissionsManager
    @State var statusMsg: String = "Completion Ready to check"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Check Status")
                .font(.title)
            
            ForEach(
                permissionsManager.permissions,
                id: \.identifier.id,
                content: { permission in
                    Button {
                        permission.checkAuthorization { status in
                            statusMsg = "Status for \(permission.identifier.name) is: \(status.localizedDescription)"
                        }
                    } label: {
                        Label(permission.identifier.name, systemImage: permission.icons.mainIcon)
                    }
                })
            Text("")
            Text(statusMsg)
                .font(.headline)
            Divider()
        }
    }
}

struct AsyncPermissionsManagerView: View {
    let permissionsManager: PermissionsManager
    @State var statusMsg: String = "Async Ready to check"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Async Status Check")
                .font(.title)
            
            ForEach(
                permissionsManager.permissions,
                id: \.identifier.id,
                content: { permission in
                    Button {
                        Task {
                            do {
                                let status = await permission.returnAuthorizationStatus()
                                statusMsg = "Status for \(permission.identifier.name) is: \(status.localizedDescription)"
                            }
                        }
                    } label: {
                        Label(permission.identifier.name, systemImage: permission.icons.mainIcon)
                    }
                })
            Text("")
            Text(statusMsg)
                .font(.headline)
            Divider()
        }
    }
}
