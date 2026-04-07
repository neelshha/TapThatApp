import AppKit
import SwiftUI

@main
struct TapHaloLauncherApp: App {
    init() {
        launchMainAppIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }

    private func launchMainAppIfNeeded() {
        let mainAppBundleID = "com.neelshha.TapHalo"

        let isRunning = NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == mainAppBundleID
        }

        guard !isRunning else {
            NSApp.terminate(nil)
            return
        }

        let mainAppURL = resolveMainApplicationURL()

        let config = NSWorkspace.OpenConfiguration()
        config.activates = true

        NSWorkspace.shared.openApplication(at: mainAppURL, configuration: config) { _, error in
            if let error {
                print("Failed to launch TapHalo: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                NSApp.terminate(nil)
            }
        }
    }

    /// When embedded in `TapHalo.app/Contents/Library/LoginItems/`, the host app is three levels above the helper bundle.
    private func resolveMainApplicationURL() -> URL {
        let launcherBundle = Bundle.main.bundleURL

        if launcherBundle.pathComponents.contains("LoginItems") {
            return launcherBundle
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
        }

        #if DEBUG
        let sibling = launcherBundle
            .deletingLastPathComponent()
            .appendingPathComponent("TapHalo.app", isDirectory: true)
        if FileManager.default.fileExists(atPath: sibling.path) {
            return sibling
        }
        #endif

        return URL(fileURLWithPath: "/Applications/TapHalo.app", isDirectory: true)
    }
}
