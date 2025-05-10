import SwiftUI
import AppKit

struct AppIcon: Identifiable {
    let id = UUID()
    let name: String
    let icon: NSImage
    let path: String
}

struct ContentView: View {
    let apps: [AppIcon]
    let position: CGPoint
    let radius: CGFloat
    let showNames: Bool
    let iconSize: CGFloat // ← add this

    @State private var selectedIndex: Int = 0
    @State private var hoveredIndex: Int?

    var body: some View {
        ZStack {
            ForEach(Array(apps.enumerated()), id: \.element.id) { index, app in
                let angle = Angle.degrees(Double(index) / Double(apps.count) * 360)
                let x = cos(angle.radians) * radius
                let y = sin(angle.radians) * radius

                VStack(spacing: 6) {
                    Image(nsImage: app.icon)
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: selectedIndex == index ? iconSize + 8 : iconSize,
                               height: selectedIndex == index ? iconSize + 8 : iconSize)
                        .background(Color.black.opacity(0.001))
                        .contentShape(Rectangle())
                        .drawingGroup()
                        .shadow(color: hoveredIndex == index ? Color.accentColor.opacity(0.4) : .clear,
                                radius: hoveredIndex == index ? 18 : 0)
                        .scaleEffect(hoveredIndex == index ? 1.12 : 1.0)
                        .animation(.easeOut(duration: 0.18), value: hoveredIndex)
                        .onTapGesture {
                            launchApp(at: app.path)
                        }
                        .onHover { hovering in
                            hoveredIndex = hovering ? index : nil
                        }

                    if showNames {
                        Text(app.name)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .opacity(0.85)
                            .transition(.opacity)
                    }
                }
                .position(x: position.x + x, y: position.y + y)
                .animation(.easeInOut(duration: 0.18), value: selectedIndex)
            }
        }
        .frame(width: NSScreen.main?.frame.width ?? 800,
               height: NSScreen.main?.frame.height ?? 600)
        .background(Color.clear)
        .focusable()
        .onAppear {
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        .onKeyDown { event in
            switch event.keyCode {
            case 123: selectedIndex = (selectedIndex - 1 + apps.count) % apps.count
            case 124: selectedIndex = (selectedIndex + 1) % apps.count
            case 36: launchApp(at: apps[selectedIndex].path)
            default: break
            }
        }
    }

    private func launchApp(at path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }
}
