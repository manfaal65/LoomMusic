//
//  RootView.swift
//  LoomMusic
//

import SwiftUI

struct RootView: View {
    @State private var selectedTab: NavTab = .home

    var body: some View {
        VStack(spacing: 0) {
            HeaderBar(selectedTab: $selectedTab)

            switch selectedTab {
            case .home:
                HomeView()
            case .lyricsHub:
                LyricsHubView()
            default:
                PlaceholderScreen(tab: selectedTab)
            }

            PlayerBar()
        }
        .background(Color.loomBackground)
        .frame(minWidth: 900, minHeight: 600)
    }
}

#Preview {
    RootView()
}
