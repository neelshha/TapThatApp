import SwiftUI

struct KeyDownModifier: ViewModifier {
    let perform: (NSEvent) -> Void

    func body(content: Content) -> some View {
        content.background(KeyboardView(perform: perform))
    }

    struct KeyboardView: NSViewRepresentable {
        let perform: (NSEvent) -> Void

        func makeNSView(context: Context) -> NSView {
            let view = NSView()
            view.window?.makeFirstResponder(view)
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
                perform($0)
                return nil
            }
            return view
        }

        func updateNSView(_ nsView: NSView, context: Context) {}
    }
}

extension View {
    func onKeyDown(perform: @escaping (NSEvent) -> Void) -> some View {
        self.modifier(KeyDownModifier(perform: perform))
    }
}
