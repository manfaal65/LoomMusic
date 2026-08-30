//
//  RecentSection.swift
//  LoomMusic
//

import SwiftUI

struct RecentSection: View {
    var tracks: [RecentTrack] = RecentTrack.sample
    var onSelect: (RecentTrack) -> Void = { _ in }

    private let columns = [GridItem(.adaptive(minimum: 264, maximum: 320), spacing: Theme.Spacing.large)]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeader(title: "Recent", trailingTitle: "Show More")

            Rectangle()
                .fill(Color.loomDivider)
                .frame(height: 1)

            if tracks.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: Theme.Spacing.large) {
                    ForEach(tracks) { track in
                        RecentCard(track: track) {
                            onSelect(track)
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 24))
                .foregroundStyle(Color.loomTextSecondary)
            Text("Search for a song above to see it here")
                .font(.system(size: 13))
                .foregroundStyle(Color.loomTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    ScrollView {
        RecentSection()
            .padding()
    }
    .background(Color.loomBackground)
}
