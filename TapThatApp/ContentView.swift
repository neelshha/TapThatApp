import SwiftUI
import AppKit
import UniformTypeIdentifiers

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
    let iconSize: CGFloat

    @State private var selectedIndex: Int = 0
    @State private var hoveredIndex: Int?
    @State private var isVisible = true
    @State private var iconScales: [UUID: CGFloat] = [:]
    @State private var iconRotations: [UUID: Double] = [:]
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0

    // Animation constants
    private let hoverScale: CGFloat = 1.18
    private let hoverRotation: Double = 10
    private let clickScale: CGFloat = 0.95
    private let clickRotation: Double = -2

    var body: some View {
        // --- Calculations ---
        let margin: CGFloat = 4
        let n = max(apps.count, 1)
        let angle = 2 * .pi / CGFloat(n)
        let minRadius = (iconSize + margin) / (1.5 * sin(angle / 2))
        let ringThickness = max(iconSize * 1.5, 48)
        let dynamicRadius = minRadius + ringThickness * 0.25

        // --- Views ---
        return ZStack {
            // Donut-shaped background (dark, minimal thickness)
            DonutShape(
                center: position,
                outerRadius: dynamicRadius + ringThickness / 2,
                innerRadius: dynamicRadius - ringThickness / 2
            )
            .fill(Color.black.opacity(0.78))
            .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 2)
            .scaleEffect(ringScale)
            .opacity(ringOpacity)

            // App icons
            ForEach(Array(apps.enumerated()), id: \.element.id) { index, app in
                let angle = Angle.degrees(Double(index) / Double(apps.count) * 360)
                let x = cos(angle.radians) * dynamicRadius
                let y = sin(angle.radians) * dynamicRadius
                VStack(spacing: 6) {
                    Image(nsImage: app.icon)
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        .scaleEffect(iconScales[app.id] ?? 1.0)
                        .rotationEffect(.degrees(iconRotations[app.id] ?? 0))
                        .shadow(color: hoveredIndex == index ? Color.accentColor.opacity(0.45) : Color.black.opacity(0.13), 
                               radius: hoveredIndex == index ? 14 : 4, x: 0, y: 2)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                iconScales[app.id] = clickScale
                                iconRotations[app.id] = clickRotation
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    iconScales[app.id] = 1.0
                                    iconRotations[app.id] = 0
                                }
                                launchApp(at: app.path)
                            }
                        }
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                hoveredIndex = hovering ? index : nil
                                if hovering {
                                    iconScales[app.id] = hoverScale
                                    iconRotations[app.id] = hoverRotation
                                } else {
                                    iconScales[app.id] = 1.0
                                    iconRotations[app.id] = 0
                                }
                            }
                        }
                }
                .position(x: position.x + x, y: position.y + y)
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.5)
                            .combined(with: .opacity)
                            .animation(.easeOut(duration: 0.3).delay(Double(index) * 0.03)),
                        removal: .scale(scale: 0.5)
                            .combined(with: .opacity)
                            .animation(.easeIn(duration: 0.2))
                    )
                )
            }

            // Central label for hovered app
            if let hovered = hoveredIndex, apps.indices.contains(hovered) {
                let app = apps[hovered]
                
                Text(app.name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(.sRGB, white: 0.13, opacity: 1.0))
                            .shadow(color: Color.black.opacity(0.18), radius: 1, x: 0, y: 2)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color(.sRGB, white: 0.25, opacity: 1.0), lineWidth: 2)
                    )
                    .position(x: position.x, y: position.y)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.15), value: hoveredIndex)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .focusable()
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                ringScale = 1.0
                ringOpacity = 1.0
            }
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                isVisible = true
            }
        }
        .onKeyDown { event in
            switch event.keyCode {
            case 123: 
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedIndex = (selectedIndex - 1 + apps.count) % apps.count
                }
            case 124: 
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedIndex = (selectedIndex + 1) % apps.count
                }
            case 36: 
                if let app = apps[safe: selectedIndex] {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        iconScales[app.id] = clickScale
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            iconScales[app.id] = 1.0
                        }
                        launchApp(at: app.path)
                    }
                }
            default: break
            }
        }
    }

    private func launchApp(at path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.appearance = NSAppearance(named: .darkAqua)
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

struct RadialSegment: Shape {
    let center: CGPoint
    let innerRadius: CGFloat
    let outerRadius: CGFloat
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
//        let start = CGFloat(startAngle.radians)
//        let end = CGFloat(endAngle.radians)
        let center = self.center

        path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        path.closeSubpath()
        return path
    }
}

struct DonutShape: Shape {
    let center: CGPoint
    let outerRadius: CGFloat
    let innerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: center, radius: outerRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        path.addArc(center: center, radius: innerRadius, startAngle: .degrees(360), endAngle: .degrees(0), clockwise: true)
        path.closeSubpath()
        return path
    }
}

// Helper for conditional modifier
extension View {
    @ViewBuilder func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

// Helper extension for safe array access
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
