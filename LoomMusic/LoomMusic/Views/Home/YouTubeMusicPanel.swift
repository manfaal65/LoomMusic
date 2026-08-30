//
//  YouTubeMusicPanel.swift
//  LoomMusic
//

import SwiftUI

struct YouTubeMusicPanel: View {
    let request: YouTubeMusicRequest
    var onClose: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("YouTube Music")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Button(action: onClose) {
                    HStack(spacing: 4) {
                        Text("Close")
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(Color.loomTextSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.vertical, Theme.Spacing.medium)

            Rectangle()
                .fill(Color.loomDivider)
                .frame(height: 1)

            YouTubeMusicWebView(request: request) { videoId, title in
                PlaybackHistoryStore.shared.recordPlayed(
                    videoId: videoId,
                    title: title,
                    thumbnailURL: URL(string: "https://i.ytimg.com/vi/\(videoId)/hqdefault.jpg")
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.loomBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .stroke(Color.loomDivider, lineWidth: 1)
        )
    }
}
