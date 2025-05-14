import AppKit
import Cocoa
import SwiftUI
import HotKey

class LauncherController {
    private var window: NSWindow?
    private var hotKey: HotKey?
    private let store = SettingsStore() // Shared settings store
    private var isShowing = false

    init() {
        hotKey = HotKey(key: .space, modifiers: [.option])

        hotKey?.keyDownHandler = { [weak self] in
            print("🔽 Option + Space pressed")
            self?.showLauncher()
        }

        hotKey?.keyUpHandler = { [weak self] in
            print("🔼 Option + Space released")
            // Only hide if we're actually showing
            if self?.isShowing == true {
            self?.hideLauncher()
            }
        }
    }

    func showLauncher() {
        store.loadSelectedApps() // Always reload latest apps from UserDefaults
        if window != nil { 
            print("⚠️ Window already exists, returning")
            return 
        }

        print("🔄 Creating launcher window...")
        let selectedPaths = store.selectedAppPaths
        print("📱 Selected apps: \(selectedPaths.count)")
        
        let apps: [AppIcon] = selectedPaths.compactMap { path in
            let url = URL(fileURLWithPath: path)
            guard FileManager.default.fileExists(atPath: path) else { 
                print("❌ App not found: \(path)")
                return nil 
            }
            let name = url.deletingPathExtension().lastPathComponent
            let icon = NSWorkspace.shared.icon(forFile: path)
            icon.size = NSSize(width: store.iconSize, height: store.iconSize)
            return AppIcon(name: name, icon: icon, path: path)
        }
        
        print("🎯 Creating ContentView with \(apps.count) apps")
        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let screenHeight = screen.frame.height
        
        print("📍 Mouse location: \(mouseLocation)")
        print("🖥️ Screen height: \(screenHeight)")
        
        // Calculate true outer radius and window size
        let radius = CGFloat(store.ringRadius)
        let iconSize = CGFloat(store.iconSize)
        let margin: CGFloat = 16 // for shadow or extra space
        let outerRadius = radius + iconSize / 2 + margin
        let windowSize = outerRadius * 2
        
        print("📏 Radius: \(radius), Icon size: \(iconSize), Outer radius: \(outerRadius), Window size: \(windowSize)")
        
        // Center window at cursor
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
        
        print("📐 Creating window at frame: \(windowFrame)")

        let contentView = ContentView(
            apps: apps,
            position: CGPoint(x: windowSize / 2, y: windowSize / 2), // Center at window center
            radius: radius,
            showNames: store.showNames,
            iconSize: iconSize
        )
        let hostingController = NSHostingController(rootView: contentView)

        print("🎨 Creating NSWindow...")
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

        // Activate app BEFORE showing window
        NSApp.activate(ignoringOtherApps: true)
        
        // Show window
        window.setFrame(windowFrame, display: true)
        window.orderFrontRegardless()
        window.makeKey()

        self.window = window
        self.isShowing = true
        print("✅ Window shown with level: \(window.level.rawValue) and frame: \(window.frame)")
    }

    func hideLauncher() {
        print("🔄 Hiding launcher...")
        window?.close()
        window = nil
        isShowing = false
        print("✅ Launcher hidden")
    }

    private func getMousePosition() -> CGPoint {
        let mouseLocation = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0
        return CGPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)
    }
}
