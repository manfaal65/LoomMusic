//
//  RootView.swift
//  LoomMusic
//

import SwiftUI

struct RootView: View {
    @State private var selectedTab: NavTab = .home
    @State private var showPaywall = false
    @State private var showSettings = false
    @ObservedObject private var store = StoreKitService.shared

    var body: some View {
        VStack(spacing: 0) {
            HeaderBar(
                selectedTab: $selectedTab,
                onSettingsTap: { showSettings = true }
            )

            switch selectedTab {
            case .home:
                HomeView()
            case .lyricsHub:
                LyricsHubView()
            case .aiLyricsGenerator:
                AILyricsGeneratorView()
            case .aiSongSummary:
                AISongSummaryView()
            case .upload:
                UploadView()
            }

            PlayerBar(onPremiumTap: { showPaywall = true })
        }
        .background(Color.loomBackground)
        .frame(minWidth: 900, minHeight: 600)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(onOpenPaywall: {
                showSettings = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showPaywall = true
                }
            })
        }
        .task {
            // Briefly pause for window initialization and StoreKit entitlement check
            try? await Task.sleep(nanoseconds: 350_000_000)
            if !store.isPremiumActive {
                showPaywall = true
            }
        }
        .background(
            Button(action: { showSettings = true }) {}
                .keyboardShortcut(",", modifiers: .command)
                .opacity(0)
        )
    }
}

#Preview {
    RootView()
}
