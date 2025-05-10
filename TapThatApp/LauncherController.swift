import AppKit
import Cocoa
import SwiftUI
import HotKey

class LauncherController {
    private var panel: NSPanel?
    private var hotKey: HotKey?
    private let store = SettingsStore() // Shared settings store

    init() {
        hotKey = HotKey(key: .space, modifiers: [.option])

        hotKey?.keyDownHandler = { [weak self] in
            self?.showLauncher()
        }

        hotKey?.keyUpHandler = { [weak self] in
            self?.hideLauncher()
        }
    }

    func showLauncher() {
        if panel != nil { return } // avoid duplicates

        let selectedPaths = SettingsStore().selectedAppPaths
        let apps: [AppIcon] = selectedPaths.compactMap { path in
            let url = URL(fileURLWithPath: path)
            guard FileManager.default.fileExists(atPath: path) else { return nil }
            let name = url.deletingPathExtension().lastPathComponent
            let icon = NSWorkspace.shared.icon(forFile: path)
            icon.size = NSSize(width: 48, height: 48)
            return AppIcon(name: name, icon: icon, path: path)
        }
        let position = getMousePosition()
        let radius = CGFloat(store.ringRadius)

        let contentView = ContentView(
            apps: apps,
            position: position,
            radius: radius,
            showNames: store.showNames,
            iconSize: CGFloat(store.iconSize)
        )
        let hostingController = NSHostingController(rootView: contentView)

        let screenFrame = NSScreen.main?.frame ?? .zero
        let panel = NSPanel(contentRect: screenFrame,
                            styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered,
                            defer: false)

        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = false
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.contentViewController = hostingController
        panel.orderFrontRegardless()

        self.panel = panel
    }

    func hideLauncher() {
        panel?.close()
        panel = nil
    }

    private func getMousePosition() -> CGPoint {
        let mouseLocation = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0
        return CGPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)
    }
}
