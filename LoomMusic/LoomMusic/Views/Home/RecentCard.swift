//
//  RecentCard.swift
//  LoomMusic
//

import SwiftUI

struct RecentCard: View {
    let track: RecentTrack

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                thumbnailBackground

                LinearGradient(
                    colors: [.black.opacity(0.85), .black.opacity(0)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 70)
                .frame(maxHeight: .infinity, alignment: .bottom)

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(track.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(1)
                }
                .padding(12)
            }
            .aspectRatio(16 / 10, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))

            Text(track.caption)
                .font(.system(size: 13))
                .foregroundStyle(Color.loomTextSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var thumbnailBackground: some View {
        switch track.thumbnail {
        case let .placeholder(symbolName, gradientColors):
            ZStack {
                LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: symbolName)
                    .font(.system(size: 34))
                    .foregroundStyle(.white.opacity(0.25))
            }
        }
    }
}

#Preview {
    RecentCard(track: RecentTrack.sample[0])
        .frame(width: 264)
        .padding()
        .background(Color.loomBackground)
}
