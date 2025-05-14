import Foundation
import SwiftUI

class SettingsStore: ObservableObject {
    @AppStorage("showNames") var showNames: Bool = false
    @AppStorage("iconSize") var iconSize: Double = 48
    @AppStorage("ringRadius") var ringRadius: Double = 160

    @Published var selectedAppPaths: [String] = []

    private let appPathsKey = "selectedAppPaths"

    var computedRadius: Double {
        return ringRadius // Use the stored ring radius
    }

    init() {
        loadSelectedApps()
        if selectedAppPaths.isEmpty {
            loadDefaultApps()
        }
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

    private func loadDefaultApps() {
        let defaultApps = [
            "/Applications/Safari.app",
            "/Applications/Mail.app",
            "/Applications/Notes.app",
            "/Applications/Calendar.app"
        ]
        
        for appPath in defaultApps {
            if FileManager.default.fileExists(atPath: appPath) {
                selectedAppPaths.append(appPath)
            }
        }
        saveSelectedApps()
    }
}
