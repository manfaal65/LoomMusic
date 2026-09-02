//
//  RecentCard.swift
//  LoomMusic
//

import SwiftUI

struct RecentCard: View {
    let track: RecentTrack
    var onSelect: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        Button(action: onSelect) {
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
                .overlay(alignment: .topTrailing) {
                    deleteButton
                        .padding(8)
                }

                Text(track.caption)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.loomTextSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.black.opacity(0.55)))
        }
        .buttonStyle(.plain)
        .help("Remove from Recent")
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
        case let .remote(url):
            // AsyncImage's resizable image has no intrinsic frame of its own, so without
            // clamping it to the card's actual measured size here, its native pixel
            // dimensions leak upward as the ZStack's "ideal" size — combined with
            // .aspectRatio(contentMode: .fill) on the outer ZStack (which is allowed to
            // overflow its proposed size by design), the card balloons to roughly the
            // image's real resolution and the oversized result looks pixelated.
            GeometryReader { proxy in
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                    default:
                        ZStack {
                            Color.loomSurface
                            Image(systemName: "music.note")
                                .font(.system(size: 34))
                                .foregroundStyle(.white.opacity(0.25))
                        }
                    }
                }
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
