import AppKit
import Cocoa
import SwiftUI
import HotKey

class LauncherController {
    private var window: NSWindow?
    private var hotKey: HotKey?
    private let store = SettingsStore()
    private var isShowing = false
    private var securityScopedStops: [() -> Void] = []

    init() {
        hotKey = HotKey(key: .space, modifiers: [.option])

        hotKey?.keyDownHandler = { [weak self] in
            self?.showLauncher()
        }

        hotKey?.keyUpHandler = { [weak self] in
            if self?.isShowing == true {
                self?.hideLauncher()
            }
        }
    }

    func showLauncher() {
        store.loadBookmarks()
        if window != nil {
            return
        }

        releaseSecurityScopedURLs()

        let pairs = store.resolveAppsForAccess()
        securityScopedStops = pairs.map { $0.stopAccess }

        let apps: [AppIcon] = pairs.compactMap { pair in
            let url = pair.url
            let path = url.path
            guard FileManager.default.fileExists(atPath: path) else {
                return nil
            }
            let name = url.deletingPathExtension().lastPathComponent
            let icon = NSWorkspace.shared.icon(forFile: path)
            icon.size = NSSize(width: store.iconSize, height: store.iconSize)
            return AppIcon(name: name, icon: icon, url: url)
        }

        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.main ?? NSScreen.screens[0]
        _ = screen.frame.height

        let radius = CGFloat(store.ringRadius)
        let iconSize = CGFloat(store.iconSize)
        let margin: CGFloat = 16
        let outerRadius = radius + iconSize / 2 + margin
        let windowSize = outerRadius * 2

        let windowOrigin = NSPoint(
            x: mouseLocation.x - windowSize / 2,
            y: mouseLocation.y - windowSize / 2
        )

        let windowFrame = NSRect(
            x: windowOrigin.x,
            y: windowOrigin.y,
            width: windowSize,
            height: windowSize
        )

        let contentView = ContentView(
            apps: apps,
            position: CGPoint(x: windowSize / 2, y: windowSize / 2),
            radius: radius,
            showNames: store.showNames,
            iconSize: iconSize
        )
        let hostingController = NSHostingController(rootView: contentView)

        let window = NSWindow(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hostingController
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        window.hidesOnDeactivate = false
        window.isMovableByWindowBackground = false
        window.isReleasedWhenClosed = false

        NSApp.activate(ignoringOtherApps: true)

        window.setFrame(windowFrame, display: true)
        window.orderFrontRegardless()
        window.makeKey()

        self.window = window
        self.isShowing = true
    }

    func hideLauncher() {
        window?.close()
        window = nil
        isShowing = false
        releaseSecurityScopedURLs()
    }

    private func releaseSecurityScopedURLs() {
        securityScopedStops.forEach { $0() }
        securityScopedStops = []
    }
}
