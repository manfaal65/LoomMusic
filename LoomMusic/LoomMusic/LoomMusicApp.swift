//
//  LoomMusicApp.swift
//  LoomMusic
//
//  Created by Muhammad Anfaal on 30/08/2026.
//

import SwiftUI

@main
struct LoomMusicApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1100, height: 720)
    }
}
