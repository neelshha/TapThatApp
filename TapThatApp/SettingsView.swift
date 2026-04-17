import SwiftUI
import AppKit
import ServiceManagement
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var store: SettingsStore
    @State private var isRecordingShortcut = false

    private let sizeOptions: [(label: String, size: Double)] = [
        ("S", 40), ("M", 48), ("L", 56), ("XL", 64)
    ]

    private let radiusOptions: [(label: String, radius: Double)] = [
        ("S", 130), ("M", 160), ("L", 190), ("XL", 220)
    ]

    private var selectedAppIcons: [AppIcon] {
        store.appIcons(accessing: store.iconSize)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            previewColumn
                .frame(width: 372)

            Divider()

            Form {
                Section {
                    Toggle("Show app names on hover", isOn: $store.showNames)

                    Picker("Icon size", selection: $store.iconSize) {
                        ForEach(sizeOptions, id: \.size) { option in
                            Text(option.label).tag(option.size)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityHint("Relative size of app icons in the ring.")

                    Picker("Ring radius", selection: $store.ringRadius) {
                        ForEach(radiusOptions, id: \.radius) { option in
                            Text(option.label).tag(option.radius)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityHint("How far icons sit from the center of the ring.")
                } header: {
                    Text("Ring")
                }

                if #available(macOS 13.0, *) {
                    Section {
                        OpenAtLoginSection()
                    } header: {
                        Text("Open at Login")
                    } footer: {
                        Text("If macOS asks you to approve the login item, choose TapThatApp in System Settings → General → Login Items & Extensions.")
                    }
                }

                Section {
                    HStack {
                        Text("Activate halo")
                        Spacer()
                        Button(shortcutDisplayName) {
                            isRecordingShortcut = true
                        }
                        .buttonStyle(.bordered)
                        .help("Click and press a new shortcut.")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityHint("Sets the keyboard shortcut used to toggle the app ring.")
                } header: {
                    Text("Shortcut")
                } footer: {
                    Text("Default is Option + Space.")
                }

                Section {
                    Button {
                        presentAddApplicationsPanel()
                    } label: {
                        Label("Add Applications…", systemImage: "plus.app.fill")
                    }

                    if store.bookmarkDataList.isEmpty {
                        emptyAppsPlaceholder
                    } else {
                        ForEach(Array(selectedAppIcons.enumerated()), id: \.offset) { index, app in
                            HStack(spacing: 10) {
                                Image(nsImage: app.icon)
                                    .resizable()
                                    .interpolation(.high)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                Text(app.name)
                                    .lineLimit(1)
                                Spacer(minLength: 8)
                                Button(role: .destructive) {
                                    store.removeApp(at: index)
                                } label: {
                                    Label("Remove", systemImage: "minus.circle.fill")
                                        .labelStyle(.iconOnly)
                                }
                                .buttonStyle(.borderless)
                                .help("Remove “\(app.name)” from the ring")
                                .accessibilityLabel("Remove \(app.name)")
                            }
                            .padding(.vertical, 2)
                        }
                    }
                } header: {
                    Text("Apps in Ring")
                } footer: {
                    Text("Apps must be added here so TapThatApp can open them under macOS security rules.")
                }
            }
            .formStyle(.grouped)
            .frame(minWidth: 400, maxWidth: 520)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            store.loadBookmarks()
        }
        .sheet(isPresented: $isRecordingShortcut) {
            ShortcutRecorderView(store: store)
        }
    }

    @ViewBuilder
    private var previewColumn: some View {
        GroupBox {
            ZStack {
                if selectedAppIcons.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 40, weight: .regular))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                        Text("No apps to preview")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text("Use Add Applications to choose apps for your ring.")
                            .font(.callout)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(20)
                } else {
                    let previewWidth: CGFloat = 320
                    let previewHeight: CGFloat = 400
                    let iconSize = CGFloat(store.iconSize)
                    let margin: CGFloat = 8
                    let n = max(selectedAppIcons.count, 1)
                    let angle = 2 * .pi / CGFloat(n)
                    let maxAllowedRadius = min((previewWidth - iconSize) / 2 - 16, (previewHeight - iconSize) / 2 - 16)
                    let minRadius = (iconSize + margin) / (2 * sin(angle / 2))
                    let radius = min(maxAllowedRadius, max(minRadius, 0))

                    ContentView(
                        apps: selectedAppIcons,
                        position: CGPoint(x: previewWidth / 2, y: previewHeight / 2),
                        radius: radius,
                        showNames: store.showNames,
                        iconSize: iconSize,
                        allowsAppLaunch: false
                    )
                    .frame(width: previewWidth, height: previewHeight)
                }
            }
            .frame(minHeight: 420)
        } label: {
            Label("Preview", systemImage: "square.on.square")
                .labelStyle(.titleAndIcon)
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }

    private var emptyAppsPlaceholder: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("No apps yet. Choose Add Applications to build your ring.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var shortcutDisplayName: String {
        ShortcutFormatter.displayName(
            keyCode: store.shortcutKeyCode,
            modifiers: store.shortcutModifiers
        )
    }

    private func presentAddApplicationsPanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications", isDirectory: true)
        panel.message = "Select one or more apps to add to your ring."
        panel.prompt = "Add"

        panel.begin { response in
            guard response == .OK else { return }
            for url in panel.urls {
                guard url.startAccessingSecurityScopedResource() else { continue }
                defer { url.stopAccessingSecurityScopedResource() }
                try? store.addAppBookmark(for: url)
            }
        }
    }
}

@available(macOS 13.0, *)
private struct OpenAtLoginSection: View {
    private let loginItemIdentifier = "com.neelshha.TapThatAppLauncher"

    @State private var openAtLogin = false
    @State private var statusMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Open TapThatApp at login", isOn: Binding(
                get: { openAtLogin },
                set: { newValue in
                    Task { await setLoginItem(enabled: newValue) }
                }
            ))
            .accessibilityHint("Starts the menu bar app when you log in to this Mac.")

            if let statusMessage {
                Text(statusMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { syncFromService() }
    }

    private func syncFromService() {
        let status = SMAppService.loginItem(identifier: loginItemIdentifier).status
        openAtLogin = (status == .enabled)
        if status == .requiresApproval {
            statusMessage = "Turn on TapThatApp under Login Items in System Settings."
        } else {
            statusMessage = nil
        }
    }

    private func setLoginItem(enabled: Bool) async {
        let service = SMAppService.loginItem(identifier: loginItemIdentifier)
        do {
            if enabled {
                try service.register()
            } else {
                try await service.unregister()
            }
            await MainActor.run {
                syncFromService()
            }
        } catch {
            await MainActor.run {
                statusMessage = error.localizedDescription
                syncFromService()
            }
        }
    }
}

private struct ShortcutRecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: SettingsStore
    @State private var pendingShortcutLabel = "Press your desired shortcut"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Record Shortcut")
                .font(.headline)
            Text(pendingShortcutLabel)
                .font(.body)
                .foregroundStyle(.secondary)
            Text("Use at least one modifier key (Option, Command, Control, or Shift).")
                .font(.callout)
                .foregroundStyle(.tertiary)
            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .padding(20)
        .frame(minWidth: 420)
        .background(
            ShortcutCaptureView { event in
                let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])
                guard !modifiers.isEmpty else {
                    pendingShortcutLabel = "Shortcut needs a modifier key"
                    return
                }
                store.setShortcut(keyCode: Int(event.keyCode), modifiers: modifiers)
                dismiss()
            }
        )
    }
}

private struct ShortcutCaptureView: NSViewRepresentable {
    let onCapture: (NSEvent) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        context.coordinator.startMonitoring()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.stopMonitoring()
    }

    final class Coordinator {
        private var monitor: Any?
        private let onCapture: (NSEvent) -> Void

        init(onCapture: @escaping (NSEvent) -> Void) {
            self.onCapture = onCapture
        }

        func startMonitoring() {
            stopMonitoring()
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                self?.onCapture(event)
                return nil
            }
        }

        func stopMonitoring() {
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
        }

        deinit {
            stopMonitoring()
        }
    }
}

private enum ShortcutFormatter {
    static func displayName(keyCode: Int, modifiers: NSEvent.ModifierFlags) -> String {
        let modifiersLabel = labels(for: modifiers).joined(separator: " + ")
        let keyLabel = keyName(for: UInt16(keyCode))
        if modifiersLabel.isEmpty {
            return keyLabel
        }
        return "\(modifiersLabel) + \(keyLabel)"
    }

    private static func labels(for modifiers: NSEvent.ModifierFlags) -> [String] {
        var labels: [String] = []
        if modifiers.contains(.command) { labels.append("Command") }
        if modifiers.contains(.option) { labels.append("Option") }
        if modifiers.contains(.control) { labels.append("Control") }
        if modifiers.contains(.shift) { labels.append("Shift") }
        return labels
    }

    private static func keyName(for keyCode: UInt16) -> String {
        switch keyCode {
        case 49: return "Space"
        case 36: return "Return"
        case 48: return "Tab"
        case 51: return "Delete"
        case 53: return "Escape"
        case 123: return "Left Arrow"
        case 124: return "Right Arrow"
        case 125: return "Down Arrow"
        case 126: return "Up Arrow"
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 31: return "O"
        case 32: return "U"
        case 34: return "I"
        case 35: return "P"
        case 37: return "L"
        case 38: return "J"
        case 40: return "K"
        case 45: return "N"
        case 46: return "M"
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 23: return "5"
        case 22: return "6"
        case 26: return "7"
        case 28: return "8"
        case 25: return "9"
        case 29: return "0"
        default: return "Key \(keyCode)"
        }
    }
}
