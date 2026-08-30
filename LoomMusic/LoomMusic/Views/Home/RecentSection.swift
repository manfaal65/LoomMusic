//
//  RecentSection.swift
//  LoomMusic
//

import SwiftUI

struct RecentSection: View {
    private let columns = [GridItem(.adaptive(minimum: 264, maximum: 320), spacing: Theme.Spacing.large)]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeader(title: "Recent", trailingTitle: "Show More")

            Rectangle()
                .fill(Color.loomDivider)
                .frame(height: 1)

            LazyVGrid(columns: columns, spacing: Theme.Spacing.large) {
                ForEach(RecentTrack.sample) { track in
                    RecentCard(track: track)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        RecentSection()
            .padding()
    }
    .background(Color.loomBackground)
}
