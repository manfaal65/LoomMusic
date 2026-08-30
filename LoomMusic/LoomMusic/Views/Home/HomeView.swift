//
//  HomeView.swift
//  LoomMusic
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large * 1.5) {
                SearchBar()
                RecentSection()
            }
            .padding(Theme.contentPadding)
        }
        .background(Color.loomBackground)
    }
}

#Preview {
    HomeView()
}
