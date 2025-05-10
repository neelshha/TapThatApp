import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var store: SettingsStore
    @Environment(\.presentationMode) var presentationMode

    @State private var allApps: [URL] = []

    let sizeOptions: [(label: String, size: Double)] = [
        ("XS", 32), ("S", 40), ("M", 48), ("L", 56), ("XL", 64)
    ]

    let radiusOptions: [(label: String, radius: Double)] = [
        ("XS", 100), ("S", 130), ("M", 160), ("L", 190), ("XL", 220)
    ]

    var selectedAppIcons: [AppIcon] {
        store.selectedAppPaths.compactMap { path in
            let url = URL(fileURLWithPath: path)
            guard FileManager.default.fileExists(atPath: path) else { return nil }
            let name = url.deletingPathExtension().lastPathComponent
            let icon = NSWorkspace.shared.icon(forFile: path)
            icon.size = NSSize(width: store.iconSize, height: store.iconSize)
            return AppIcon(name: name, icon: icon, path: path)
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape.fill")
                Text("TapThatApp Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding(.top)

            Form {
                Section(header: Text("General").font(.headline)) {
                    Toggle(isOn: $store.showNames) {
                        Label("Show App Names", systemImage: "text.bubble")
                    }

                    Toggle(isOn: $store.launchAtLogin) {
                        Label("Launch at Login", systemImage: "poweron")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ring Appearance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("Radius").font(.caption)
                                Picker("Ring Radius", selection: $store.ringRadius) {
                                    ForEach(radiusOptions, id: \.radius) { option in
                                        Text(option.label).tag(option.radius)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            VStack(alignment: .leading) {
                                Text("Icon Size").font(.caption)
                                Picker("App Icon Size", selection: $store.iconSize) {
                                    ForEach(sizeOptions, id: \.size) { option in
                                        Text(option.label).tag(option.size)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Live Ring Preview")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            GeometryReader { geometry in
                                ZStack {
                                    ForEach(Array(selectedAppIcons.enumerated()), id: \.element.id) { index, app in
                                        let angle = Angle.degrees(Double(index) / Double(selectedAppIcons.count) * 360)
                                        let radius = store.ringRadius
                                        let x = cos(angle.radians) * radius
                                        let y = sin(angle.radians) * radius

                                        VStack(spacing: 2) {
                                            Image(nsImage: app.icon)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: store.iconSize, height: store.iconSize)

                                            if store.showNames {
                                                Text(app.name)
                                                    .font(.caption2)
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)
                                                    .frame(width: store.iconSize + 10)
                                            }
                                        }
                                        .position(
                                            x: geometry.size.width / 2 + CGFloat(x),
                                            y: geometry.size.height / 2 + CGFloat(y)
                                        )
                                    }
                                }
                            }
                            .frame(
                                width: store.ringRadius * 2 + 100,
                                height: store.ringRadius * 2 + 100
                            )
                        }
                        .padding(.top, 10)
                    }
                }

                Section(header: Text("Manage Selected Apps").font(.headline)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Add App to Ring")
                            .font(.subheadline)

                        Menu {
                            ForEach(allApps, id: \.path) { app in
                                let name = app.deletingPathExtension().lastPathComponent
                                let icon = NSWorkspace.shared.icon(forFile: app.path)
                                let alreadySelected = store.isAppSelected(app.path)

                                Button(action: {
                                    store.toggleAppSelection(app.path)
                                }) {
                                    HStack {
                                        Image(nsImage: icon)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 16, height: 16)
                                        Text(name)
                                    }
                                }
                                .disabled(alreadySelected)
                            }
                        } label: {
                            Label("Select App", systemImage: "plus.circle")
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }

                    if store.selectedAppPaths.isEmpty {
                        Text("No apps added yet.")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    } else {
                        List {
                            ForEach(store.selectedAppPaths, id: \.self) { path in
                                HStack {
                                    Text(URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent)
                                    Spacer()
                                    Button(role: .destructive) {
                                        store.toggleAppSelection(path)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .onDelete(perform: removeSelectedApps)
                        }
                        .frame(height: 160)
                    }
                }
            }
            .formStyle(.grouped)
            .padding(.horizontal)

            Divider().padding(.bottom, 8)

            HStack {
                Spacer()
                Button("Close") {
                    store.saveSelectedApps()
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .padding(.horizontal)
            }
        }
        .frame(width: max(store.ringRadius * 2 + 140, 600), height: 720)
        .padding(.vertical)
        .onAppear {
            allApps = loadApplications()
        }
    }

    private func loadApplications() -> [URL] {
        let appDir = URL(fileURLWithPath: "/Applications")
        return (try? FileManager.default.contentsOfDirectory(at: appDir, includingPropertiesForKeys: nil))?
            .filter { $0.pathExtension == "app" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent } ?? []
    }

    private func removeSelectedApps(at offsets: IndexSet) {
        for index in offsets {
            let pathToRemove = store.selectedAppPaths[index]
            store.toggleAppSelection(pathToRemove)
        }
    }
}
