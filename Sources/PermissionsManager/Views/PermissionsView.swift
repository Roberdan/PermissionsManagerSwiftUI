//
//  Permissions View.swift
//  
//
//  Created by Roberto D’Angelo on 04/01/23.
//

import Foundation
import SwiftUI

public struct PermissionsManagerView: View {
    @ObservedObject private var permissionsManager: PermissionsManager
    @State private var skippable: Bool
    
    public init(skippable: Bool) {
        permissionsManager = .shared
        self.skippable = skippable
    }
    
    public var body: some View {
        if permissionsManager.standBy {
            Text("Permissions Manager has not been personalized yet!")
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text("AuthCheckPointTitle".localized())
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        if skippable {
                            Button {
                                permissionsManager.skipped = true
                            } label: {
                                Text("SkipMsgText".localized())
                            }
                            .buttonStyle(.bordered)
                            .disabled(!permissionsManager.allMandatoryGranted)
                        }
                    }
                    
                    Text("SomeMissingAuthNeeded".localized() + " \(permissionsManager.supportEmail)")
                    
                    Divider()
                    ForEach(permissionsManager.permissionsStatus) { permissionStatus in
                        VStack(alignment: .leading) {
                            PermissionsManagerHeaderView(permissionStatus: permissionStatus)
                            PermissionsManagerBodyView(permissionStatus: permissionStatus)
                        }
                        Divider()
                    }
                    .refreshable {
                        permissionsManager.refresh()
                    }
                }
                .multilineTextAlignment(.leading)
                .padding()
            }
        }
    }
}

struct PermissionsManagerView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsManagerView(skippable: true)
    }
}

public struct PermissionsManagerHeaderView: View {
    private var permissionStatus: PermissionStatus
    
    public init(permissionStatus: PermissionStatus) {
        self.permissionStatus = permissionStatus
    }
    
    public var body: some View {
        HStack {
            Label(permissionStatus.permission.identifier.name, systemImage: permissionStatus.permission.icons.mainIcon)
                .font(.headline)
            Spacer()
            switch permissionStatus.status {
            case .authorized:
                Text(permissionStatus.status.localizedDescription)
                    .foregroundColor(.green)
            case .notDetermined:
                Button {
                    permissionStatus.permission.requestAuthorization { status in
                        // no action required as it's all handled via events
                    }
                } label: {
                    Label("GrantItBtnLabel".localized(), systemImage: "hand.thumbsup.circle")
                }
                .buttonStyle(.bordered)
            case .denied:
                Text(permissionStatus.status.localizedDescription)
                    .foregroundColor(.red)
            case .error, .custom, .unknown, .notAvailable:
                Text(permissionStatus.status.localizedDescription)
                    .foregroundColor(.yellow)
            }
        }
    }
}

public struct PermissionsManagerBodyView: View {
    private var permissionStatus: PermissionStatus
    
    public init(permissionStatus: PermissionStatus) {
        self.permissionStatus = permissionStatus
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if permissionStatus.permission.identifier.isMandatory {
                Text("MandatoryMsg".localized())
                    .font(.caption)
                    .fontWeight(.heavy)
            }
            switch permissionStatus.status {
            case .authorized:
                Text(permissionStatus.permission.messages.okMessage)
            case .notDetermined:
                Text(permissionStatus.permission.messages.description)
            case .denied:
                Text(permissionStatus.permission.messages.noOkMessage + "\n" + permissionStatus.permission.messages.recoveryMsg)
            case .custom, .unknown, .notAvailable, .error:
                Text(permissionStatus.status.localizedDescription)
            }
        }
    }
}
