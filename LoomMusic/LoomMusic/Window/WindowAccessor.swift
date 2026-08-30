//
//  WindowAccessor.swift
//  LoomMusic
//

import SwiftUI
import AppKit

/// Bridges to the hosting NSWindow so the header row can keep the native
/// traffic-light buttons vertically centered against a taller-than-default
/// title bar, and keep the title-bar sliver dark regardless of system appearance.
struct WindowAccessor: NSViewRepresentable {
    let configure: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = AccessorView()
        view.configure = configure
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    private final class AccessorView: NSView {
        var configure: ((NSWindow) -> Void)?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            guard let window else { return }
            configure?(window)
        }
    }
}
