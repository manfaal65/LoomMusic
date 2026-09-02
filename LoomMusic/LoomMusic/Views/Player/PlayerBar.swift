//
//  PlayerBar.swift
//  LoomMusic
//

import SwiftUI

struct PlayerBar: View {
    @ObservedObject private var player = PlaybackController.shared
    var onPremiumTap: () -> Void = {}
    @State private var volume: Double = 0.6
    @State private var isScrubbing = false
    @State private var scrubProgress: Double = 0

    private var progress: Double {
        guard player.duration > 0 else { return 0 }
        return player.currentTime / player.duration
    }

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
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.small)
                    .fill(Color.black.opacity(0.3))
                if let artworkURL = player.artworkURL {
                    AsyncImage(url: artworkURL) { phase in
                        if case let .success(image) = phase {
                            image.resizable().scaledToFill()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small))
                }
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(player.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(player.artist)
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
                Button(action: player.skipPrevious) {
                    Image(systemName: "backward.end.fill")
                        .foregroundStyle(player.isConnected ? Color.loomTextSecondary : Color.loomTextSecondary.opacity(0.4))
                }
                .buttonStyle(.plain)
                .disabled(!player.isConnected)

                Button(action: player.togglePlayPause) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.black)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(.white.opacity(player.isConnected ? 1 : 0.5)))
                }
                .buttonStyle(.plain)
                .disabled(!player.isConnected)

                Button(action: player.skipNext) {
                    Image(systemName: "forward.end.fill")
                        .foregroundStyle(player.isConnected ? Color.loomTextSecondary : Color.loomTextSecondary.opacity(0.4))
                }
                .buttonStyle(.plain)
                .disabled(!player.isConnected)
            }
            .font(.system(size: 13))
            .fixedSize(horizontal: true, vertical: true)

            HStack(spacing: 10) {
                Text(Self.formatTime(player.currentTime))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.loomTextSecondary)
                    .fixedSize()
                Slider(
                    value: Binding(
                        get: { isScrubbing ? scrubProgress : progress },
                        set: { newValue in
                            isScrubbing = true
                            scrubProgress = newValue
                        }
                    ),
                    in: 0...1,
                    onEditingChanged: { editing in
                        if !editing {
                            player.seek(toFraction: scrubProgress)
                            isScrubbing = false
                        }
                    }
                )
                .controlSize(.small)
                .disabled(!player.isConnected)
                Text(Self.formatTime(player.duration))
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

            Button(action: onPremiumTap) {
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

    private static func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

#Preview {
    PlayerBar()
        .background(Color.loomBackground)
}
