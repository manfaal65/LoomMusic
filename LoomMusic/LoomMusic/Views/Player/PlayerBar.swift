//
//  PlayerBar.swift
//  LoomMusic
//

import SwiftUI

struct PlayerBar: View {
    @State private var volume: Double = 0.6
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.loomDivider)
                .frame(height: 1)

            HStack(spacing: 16) {
                nowPlaying
                    .layoutPriority(1)

                Spacer(minLength: 12)

                transport

                Spacer(minLength: 12)

                volumeAndActions
                    .layoutPriority(1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(height: 84)
        }
        .background(Color.loomSurface)
    }

    private var nowPlaying: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(Color.black.opacity(0.3))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text("Not Playing")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("Select a song to begin")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.loomTextSecondary)
                    .lineLimit(1)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .frame(minWidth: 180, alignment: .leading)
    }

    private var transport: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                Image(systemName: "backward.end.fill")
                    .foregroundStyle(Color.loomTextSecondary)
                Image(systemName: "play.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.black)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.white))
                Image(systemName: "forward.end.fill")
                    .foregroundStyle(Color.loomTextSecondary)
            }
            .font(.system(size: 13))
            .fixedSize(horizontal: true, vertical: true)

            HStack(spacing: 10) {
                Text("0:00")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.loomTextSecondary)
                    .fixedSize()
                Slider(value: $progress, in: 0...1)
                    .controlSize(.small)
                Text("0:00")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.loomTextSecondary)
                    .fixedSize()
            }
            .frame(minWidth: 220)
        }
        .frame(minWidth: 260, maxWidth: 420)
    }

    private var volumeAndActions: some View {
        HStack(spacing: 14) {
            Image(systemName: "speaker.wave.2.fill")
                .foregroundStyle(Color.loomTextSecondary)
                .fixedSize()
            Slider(value: $volume, in: 0...1)
                .controlSize(.small)
                .frame(width: 90)

            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "headphones")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Premium")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.loomPremiumGold)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .fixedSize()

            IconButton(symbolName: "sun.max")
        }
        .fixedSize(horizontal: true, vertical: false)
        .frame(minWidth: 200, alignment: .trailing)
    }
}

#Preview {
    PlayerBar()
        .background(Color.loomBackground)
}
