# PermissionsManager Package for SwiftUI
# (c) 2022 Roberdan@FightTheStroke.org for FightTheStroke Foundation (www.fightthestroke.org)
# BSD-3 License

#Rely on latest SwiftUI
    Async
    Combine events
    
#Easy to use in your app:
    import PermissionsManager
    @StateObject private var permissionsManager: PermissionsManager = PermissionsManager.shared
    
    init() {
            PermissionsManager.shared.personalize(appName: "App Name",
                                              supportEmail: "supportEmail@email.com",
                                              permissionsToHandle: [
                                                .notifications(isMandatory: true),
                                                .health(isMandatory: true),
                                                .criticalNotification(isMandatory: false),
                                                .speech(isMandatory: false),
                                                .microphone(isMandatory: false),
                                                .camera(isMandatory: false)
        ])
    }
    
    var body: View {
        if permissionsManager.canGoAhead {
        YourContentView()
    } else {
        PermissionsManagerView(skippable: true)
    }
}
    
#Expandable to new types is easy
    public class NewTypePermissionManager: PermissionManagerProtocol 
    
#Localized in 17 languages
