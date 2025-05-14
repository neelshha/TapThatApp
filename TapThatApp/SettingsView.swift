import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var store: SettingsStore
    @Environment(\.presentationMode) var presentationMode

    @State private var allApps: [URL] = []

    let sizeOptions: [(label: String, size: Double)] = [
        ("S", 40), ("M", 48), ("L", 56), ("XL", 64)
    ]

    let radiusOptions: [(label: String, radius: Double)] = [
        ("S", 130), ("M", 160), ("L", 190), ("XL", 220)
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
        HStack(spacing: 0) {
            // Left: Live Preview
            ZStack {
                if selectedAppIcons.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.secondary)
                        Text("No apps to preview")
                            .foregroundColor(.secondary)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                } else {
                    let previewWidth: CGFloat = 360
                    let previewHeight: CGFloat = 460
                    let iconSize = CGFloat(store.iconSize)
                    let margin: CGFloat = 8
                    let n = max(selectedAppIcons.count, 1)
                    let angle = 2 * .pi / CGFloat(n)
                    let maxAllowedRadius = min((previewWidth - iconSize) / 2 - 16, (previewHeight - iconSize) / 2 - 16)
                    let minRadius = (iconSize + margin) / (2 * sin(angle / 2))
                    let radius = min(maxAllowedRadius, max(minRadius, 0))
                    
                    VStack(spacing: 20) {
                        Text("PREVIEW")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        ContentView(
                            apps: selectedAppIcons,
                            position: CGPoint(x: previewWidth/2, y: previewHeight/2),
                            radius: radius,
                            showNames: store.showNames,
                            iconSize: iconSize
                        )
                        .frame(width: previewWidth, height: previewHeight)
                        .padding(.bottom, 8)
                    }
                }
            }
            .frame(width: 360, height: 460)

            Divider()
                .padding(.vertical)

            // Right: Settings UI
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    HStack(spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.accentColor)
                        Text("TapThatApp Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 8)

                    // Ring Appearance
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Icon Size")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                            Picker(selection: $store.iconSize, label: Text("")) {
                                ForEach(sizeOptions, id: \.size) { option in
                                    Text(option.label).tag(option.size)
                                }
                            }
                            .pickerStyle(.segmented)
                        .labelsHidden()
                    }
                    .padding(20)
                    .background(Color(.windowBackgroundColor).opacity(0.6))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                    // Selected Apps
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Selected Apps")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 16) {
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
                                Label("Add App", systemImage: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .menuStyle(BorderlessButtonMenuStyle())
                            .padding(.horizontal, 4)
                            
                            if store.selectedAppPaths.isEmpty {
                                Text("No apps added yet")
                                    .foregroundColor(.accentColor)
                                    .font(.subheadline)
                                    .padding(.horizontal, 4)
                            } else {
                                List {
                                    ForEach(store.selectedAppPaths, id: \.self) { path in
                                        HStack(spacing: 12) {
                                            let url = URL(fileURLWithPath: path)
                                            let icon = NSWorkspace.shared.icon(forFile: path)
                                            Image(nsImage: icon)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 20, height: 20)
                                            Text(url.deletingPathExtension().lastPathComponent)
                                                .font(.system(size: 14))
                                            Spacer()
                                            Button {
                                                store.toggleAppSelection(path)
                                            } label: {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.system(size: 16))
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .onDelete(perform: removeSelectedApps)
                                }
                                .frame(height: 360)
                                .listStyle(PlainListStyle())
                                .background(Color.clear)
                                .scrollContentBackground(.hidden)
                                .scrollIndicators(.hidden)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.windowBackgroundColor).opacity(0.6))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
            }
            .frame(minWidth: 400)
            .scrollIndicators(.hidden)
        }
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
