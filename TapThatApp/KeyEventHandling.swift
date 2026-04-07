import AppKit
import SwiftUI

struct KeyDownModifier: ViewModifier {
    let perform: (NSEvent) -> Void

    func body(content: Content) -> some View {
        content.background(KeyboardView(perform: perform))
    }

    struct KeyboardView: NSViewRepresentable {
        let perform: (NSEvent) -> Void

        func makeCoordinator() -> Coordinator {
            Coordinator(perform: perform)
        }

        final class Coordinator {
            var perform: (NSEvent) -> Void
            var monitor: Any?

            init(perform: @escaping (NSEvent) -> Void) {
                self.perform = perform
            }

            deinit {
                removeMonitorIfNeeded()
            }

            func removeMonitorIfNeeded() {
                if let monitor {
                    NSEvent.removeMonitor(monitor)
                    self.monitor = nil
                }
            }
        }

        func makeNSView(context: Context) -> NSView {
            let view = NSView()
            let coordinator = context.coordinator
            coordinator.removeMonitorIfNeeded()
            coordinator.monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                coordinator.perform(event)
                return nil
            }
            DispatchQueue.main.async {
                view.window?.makeFirstResponder(view)
            }
            return view
        }

        func updateNSView(_ nsView: NSView, context: Context) {
            context.coordinator.perform = perform
        }

        static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
            coordinator.removeMonitorIfNeeded()
        }
    }
}

extension View {
    func onKeyDown(perform: @escaping (NSEvent) -> Void) -> some View {
        modifier(KeyDownModifier(perform: perform))
    }
}
