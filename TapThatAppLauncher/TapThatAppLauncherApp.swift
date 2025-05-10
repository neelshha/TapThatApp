import SwiftUI
import AppKit

@main
struct TapThatAppLauncherApp: App {
    init() {
        launchMainAppIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            EmptyView() // Invisible UI
        }
    }

    private func launchMainAppIfNeeded() {
        let mainAppBundleID = "com.neelshha.TapThatApp"

        let isRunning = NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == mainAppBundleID
        }

        guard !isRunning else {
            NSApp.terminate(nil)
            return
        }

        #if DEBUG
        let path = "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData/TapThatApp-*/Build/Products/Debug/TapThatApp.app"
        #else
        let path = "/Applications/TapThatApp.app"
        #endif

        let url = URL(fileURLWithPath: path)
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true

        NSWorkspace.shared.openApplication(at: url, configuration: config) { app, error in
            if let error = error {
                print("❌ Failed to launch TapThatApp: \(error.localizedDescription)")
            } else {
                print("✅ TapThatApp launched successfully.")
            }

            // Always terminate the helper
            DispatchQueue.main.async {
                NSApp.terminate(nil)
            }
        }
    }
}
