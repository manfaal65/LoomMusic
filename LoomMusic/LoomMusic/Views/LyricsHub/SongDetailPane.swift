//
//  SongDetailPane.swift
//  LoomMusic
//

import SwiftUI

struct SongDetailPane: View {
    let song: Song
    @State private var selectedTab: SongDetailTab = .lyrics
    @State private var previewRequest: YouTubeMusicRequest?
    @State private var hasStartedPlaying = false
    @State private var syncOffset: TimeInterval = 0
    @ObservedObject private var player = PlaybackController.shared

    private var isPreviewing: Bool { previewRequest != nil }

    private var activeLyricLine: LyricLine? {
        guard hasStartedPlaying, !song.syncedLines.isEmpty else { return nil }
        let adjustedTime = player.currentTime + syncOffset
        var result: LyricLine?
        for line in song.syncedLines {
            guard line.time <= adjustedTime else { break }
            result = line
        }
        return result
    }

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    HStack(alignment: .top, spacing: 20) {
                        LatticePattern(colors: song.artColors)
                            .frame(width: 140, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(song.title)
                                .font(.system(size: 30, weight: .bold, design: .serif))
                                .foregroundStyle(.white)

                            Text(song.artist)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.loomTextSecondary)

                            Text("\(song.year) · \(song.duration) · \(song.genre)")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.loomTextSecondary)

                            Button(action: togglePreview) {
                                HStack(spacing: 6) {
                                    Image(systemName: isPreviewing ? "stop.fill" : "play.fill")
                                        .font(.system(size: 11, weight: .semibold))
                                    Text(isPreviewing ? "Stop" : "Preview")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.loomAccentBlue)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 6)
                        }
                    }

                    SongDetailTabPicker(selection: $selectedTab)

                    switch selectedTab {
                    case .lyrics:
                        if hasStartedPlaying && !song.syncedLines.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                syncOffsetControl
                                SyncedLyricsView(lines: song.syncedLines, activeLineID: activeLyricLine?.id)
                            }
                        } else {
                            LyricsContentView(paragraphs: song.lyrics)
                        }
                    case .songInfo:
                        SongInfoContentView(info: song.info)
                    }
                }
                .padding(Theme.Spacing.large)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.loomBackground)
            .onChange(of: activeLyricLine?.id) { _, newValue in
                guard let newValue else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
            }

            // YouTube Music gates the actual `play()` call behind a genuine
            // trusted click, separate from WebKit's own autoplay setting — a
            // script-fired click can navigate the page but won't start audio.
            // Rather than fight that (a real anti-bot/consent protection), this
            // panel stays visibly on screen just long enough for one real click
            // on the actual Play button, then collapses to a near-invisible
            // sliver the instant the bridge confirms audio is actually playing,
            // while the *same* web view instance keeps running underneath so
            // the already-granted playback session is never interrupted.
            if previewRequest != nil {
                if !hasStartedPlaying {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                }
                previewPanel
                    .frame(
                        width: hasStartedPlaying ? 2 : 640,
                        height: hasStartedPlaying ? 2 : 480
                    )
                    .opacity(hasStartedPlaying ? 0.01 : 1)
                    .allowsHitTesting(!hasStartedPlaying)
            }
        }
        .onChange(of: player.isPlaying) { _, isPlaying in
            guard isPlaying, isPreviewing, !hasStartedPlaying else { return }
            hasStartedPlaying = true
        }
    }

    // Whatever video the real click actually starts (a music video, a live cut, a
    // cover) rarely has the exact same intro/timing as the recording LRCLIB's
    // synced lyrics were timed against, so a fixed offset drifting off is expected
    // rather than a bug — this manual nudge is the same fix real lyrics apps
    // (Musixmatch, etc.) use for the same cross-source mismatch.
    private var syncOffsetControl: some View {
        HStack(spacing: 10) {
            Text("Sync")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.loomTextSecondary)

            Button(action: { syncOffset -= 0.5 }) {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.loomTextSecondary)

            Text(String(format: "%+.1fs", syncOffset))
                .font(.system(size: 12))
                .foregroundStyle(Color.loomTextSecondary)
                .monospacedDigit()
                .frame(minWidth: 42)

            Button(action: { syncOffset += 0.5 }) {
                Image(systemName: "plus.circle")
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.loomTextSecondary)

            if syncOffset != 0 {
                Button("Reset") { syncOffset = 0 }
                    .buttonStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.loomAccentBlue)
            }
        }
    }

    private var previewPanel: some View {
        VStack(spacing: 0) {
            if !hasStartedPlaying {
                HStack {
                    Text("Tap a result to play")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: togglePreview) {
                        HStack(spacing: 4) {
                            Text("Cancel")
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
            }

            if let previewRequest {
                YouTubeMusicWebView(
                    request: previewRequest,
                    autoPlayFirstResult: true,
                    onVideoOpened: { videoId, title in
                        PlaybackHistoryStore.shared.recordPlayed(
                            videoId: videoId,
                            title: title,
                            thumbnailURL: URL(string: "https://i.ytimg.com/vi/\(videoId)/hqdefault.jpg")
                        )
                    },
                    onSearchThumbnail: { query, thumbnailURL in
                        PlaybackHistoryStore.shared.updateSearchThumbnail(query: query, thumbnailURL: thumbnailURL)
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.loomBackground)
        .clipShape(RoundedRectangle(cornerRadius: hasStartedPlaying ? 0 : Theme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: hasStartedPlaying ? 0 : Theme.Radius.card)
                .stroke(hasStartedPlaying ? Color.clear : Color.loomDivider, lineWidth: 1)
        )
    }

    private func togglePreview() {
        if isPreviewing {
            previewRequest = nil
            hasStartedPlaying = false
        } else {
            let query = "\(song.title) \(song.artist)"
            PlaybackHistoryStore.shared.recordSearch(query: query)
            hasStartedPlaying = false
            syncOffset = 0
            previewRequest = .search(query)
        }
    }
}

#Preview {
    SongDetailPane(song: Song.sample[0])
}
