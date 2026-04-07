import SwiftUI
import AppKit
import ServiceManagement
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var store: SettingsStore

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
                        Text("If macOS asks you to approve the login item, choose TapHalo in System Settings → General → Login Items & Extensions.")
                    }
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
                    Text("Apps must be added here so TapHalo can open them under macOS security rules.")
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
            Toggle("Open TapHalo at login", isOn: Binding(
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
            statusMessage = "Turn on TapHalo under Login Items in System Settings."
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
