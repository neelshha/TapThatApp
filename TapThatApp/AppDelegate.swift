import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var settingsWindow: NSWindow?
    var launcher: LauncherController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        launcher = LauncherController()

        setupStatusBar()
        setupMenu()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        statusItem.button?.image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)
    }

    private func setupMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(
            title: "Launch TapThatApp",
            action: #selector(triggerLauncher),
            keyEquivalent: "L"
        ))

        menu.addItem(NSMenuItem(
            title: "Open Settings",
            action: #selector(toggleSettingsWindow),
            keyEquivalent: ","
        ))

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(
            title: "Quit TappingThatApp",
            action: #selector(quitApp),
            keyEquivalent: "q"
        ))

        statusItem.menu = menu
    }

    @objc private func triggerLauncher() {
        launcher?.showLauncher()
    }

    @objc private func toggleSettingsWindow() {
        if settingsWindow == nil {
            let store = SettingsStore()
            let settingsView = SettingsView(store: store)
            let hostingController = NSHostingController(rootView: settingsView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "TapThatApp Settings"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.setContentSize(NSSize(width: 540, height: 740))
            window.center()
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
