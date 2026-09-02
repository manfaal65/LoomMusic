//
//  RootView.swift
//  LoomMusic
//

import SwiftUI

struct RootView: View {
    @State private var selectedTab: NavTab = .home
    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: 0) {
            HeaderBar(selectedTab: $selectedTab, onUpgradeTap: { showPaywall = true })

            switch selectedTab {
            case .home:
                HomeView()
            case .lyricsHub:
                LyricsHubView()
            case .aiLyricsGenerator:
                AILyricsGeneratorView()
            case .aiSongSummary:
                AISongSummaryView()
            default:
                PlaceholderScreen(tab: selectedTab)
            }

            PlayerBar(onPremiumTap: { showPaywall = true })
        }
        .background(Color.loomBackground)
        .frame(minWidth: 900, minHeight: 600)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    RootView()
}
