import Foundation
import SwiftUI

class SettingsStore: ObservableObject {
    @AppStorage("showNames") var showNames: Bool = false
    @AppStorage("iconSize") var iconSize: Double = 48
    @AppStorage("ringRadius") var ringRadius: Double = 160
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet {
            LoginItemManager.enableLaunchAtLogin(launchAtLogin)
        }
    }

    @Published var selectedAppPaths: [String] = []

    private let appPathsKey = "selectedAppPaths"

    var computedRadius: Double {
        return 160 // fixed radius for all sizes (can be dynamic if needed)
    }

    init() {
        loadSelectedApps()
    }

    func loadSelectedApps() {
        if let saved = UserDefaults.standard.array(forKey: appPathsKey) as? [String] {
            self.selectedAppPaths = saved
        }
    }

    func saveSelectedApps() {
        UserDefaults.standard.set(selectedAppPaths, forKey: appPathsKey)
    }

    func isAppSelected(_ path: String) -> Bool {
        selectedAppPaths.contains(path)
    }

    func toggleAppSelection(_ path: String) {
        if let index = selectedAppPaths.firstIndex(of: path) {
            selectedAppPaths.remove(at: index)
        } else {
            selectedAppPaths.append(path)
        }
        saveSelectedApps()
    }
}
