import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var settingsWindow: NSWindow?
    var launcher: LauncherController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        setupStatusBar()
        launcher = LauncherController()
        setupMenu()
        NSApp.setActivationPolicy(.accessory)
    }

    private func setupStatusBar() {
        if statusItem != nil {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem.button else { return }
        let icon = NSImage(systemSymbolName: "star.circle.fill", accessibilityDescription: "TapHalo")
        icon?.size = NSSize(width: 18, height: 18)
        icon?.isTemplate = true
        button.image = icon
        button.target = self
        button.action = #selector(statusBarButtonClicked(_:))
        button.isEnabled = true
    }

    private func setupMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        let launchItem = NSMenuItem(title: "Show App Ring", action: #selector(triggerLauncher), keyEquivalent: "l")
        launchItem.image = NSImage(systemSymbolName: "circle.grid.cross", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        menu.addItem(launchItem)
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(toggleSettingsWindow), keyEquivalent: ",")
        settingsItem.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        menu.addItem(settingsItem)
        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "Quit TapHalo", action: #selector(quitApp), keyEquivalent: "q")
        menu.addItem(quitItem)
        statusItem.menu = menu
    }

    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {}

    @objc private func triggerLauncher() {
        launcher?.showLauncher()
    }

    @objc private func toggleSettingsWindow() {
        if settingsWindow == nil {
            let store = SettingsStore()
            let settingsView = SettingsView(store: store)
            let hostingController = NSHostingController(rootView: settingsView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "TapHalo Settings"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(NSSize(width: 880, height: 620))
            window.contentMinSize = NSSize(width: 760, height: 520)
            window.center()
            window.isReleasedWhenClosed = false
            window.backgroundColor = .windowBackgroundColor
            window.titlebarAppearsTransparent = false
            settingsWindow = window
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
