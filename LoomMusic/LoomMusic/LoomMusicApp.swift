//
//  LoomMusicApp.swift
//  LoomMusic
//
//  Created by Muhammad Anfaal on 30/08/2026.
//

import SwiftUI
import FirebaseCore

// SwiftUI's App protocol has no launch-lifecycle hook of its own on macOS, so
// Firebase's setup call needs an NSApplicationDelegate (the AppKit equivalent of
// the UIApplicationDelegate pattern in Firebase's iOS quickstart) hooked in via
// @NSApplicationDelegateAdaptor.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()

        // Warms the Remote Config cache at launch so the first "Analyze Track" tap
        // isn't waiting on a fresh fetch.
        Task {
            try? await RemoteConfigService.shared.fetchAndActivate()
        }

        // Loads subscription products at launch so the paywall has live prices
        // ready the moment it's opened instead of waiting on a fetch there.
        Task {
            await StoreKitService.shared.loadProducts()
        }
    }
}

@main
struct LoomMusicApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1100, height: 720)
    }
}
