//
//  SongDetailPane.swift
//  LoomMusic
//

import SwiftUI

struct SongDetailPane: View {
    let song: Song
    @State private var selectedTab: SongDetailTab = .lyrics
    @State private var syncOffset: TimeInterval = 0
    @ObservedObject private var player = PlaybackController.shared
    @ObservedObject private var uploadedStore = UploadedTracksStore.shared

    private var matchingLocalTrack: UploadedTrack? {
        let titleLower = song.title.lowercased()
        return uploadedStore.tracks.first { track in
            let localLower = track.title.lowercased()
            return localLower.contains(titleLower) || titleLower.contains(localLower)
        }
    }

    private var isPlayingMatchingTrack: Bool {
        guard let matching = matchingLocalTrack else { return false }
        return player.isPlaying && player.activeLocalTrackID == matching.id
    }

    private var activeLyricLine: LyricLine? {
        guard player.isPlaying, !song.syncedLines.isEmpty else { return nil }
        let adjustedTime = player.currentTime + syncOffset
        var result: LyricLine?
        for line in song.syncedLines {
            guard line.time <= adjustedTime else { break }
            result = line
        }
        return result
    }

    var body: some View {
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

                            if let matchingTrack = matchingLocalTrack {
                                Button(action: { togglePlayback(for: matchingTrack) }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: isPlayingMatchingTrack ? "pause.fill" : "play.fill")
                                            .font(.system(size: 11, weight: .semibold))
                                        Text(isPlayingMatchingTrack ? "Pause" : "Play Audio")
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
                            } else if player.isPlaying {
                                HStack(spacing: 6) {
                                    Image(systemName: "waveform")
                                        .font(.system(size: 11, weight: .semibold))
                                    Text("Synced to Player")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundStyle(Color.loomAccentBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.loomAccentBlue.opacity(0.12))
                                .clipShape(Capsule())
                                .padding(.top, 6)
                            }
                        }
                    }

                    SongDetailTabPicker(selection: $selectedTab)

                    switch selectedTab {
                    case .lyrics:
                        if player.isPlaying && !song.syncedLines.isEmpty {
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
    }

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

    private func togglePlayback(for track: UploadedTrack) {
        if isPlayingMatchingTrack {
            player.togglePlayPause()
        } else {
            player.playLocal(track, queue: uploadedStore.tracks)
        }
    }
}

#Preview {
    SongDetailPane(song: Song.sample[0])
}
