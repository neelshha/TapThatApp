import ServiceManagement

enum LoginItemManager {
    static let launcherID = "com.neelshha.TapThatAppLauncher"

    static func enableLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.loginItem(identifier: launcherID).register()
                print("✅ Login item registered")
            } else {
                try SMAppService.loginItem(identifier: launcherID).unregister()
                print("❌ Login item unregistered")
            }
        } catch {
            print("❌ Failed to update login item: \(error.localizedDescription)")
        }
    }
}
