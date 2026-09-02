//
//  UploadView.swift
//  LoomMusic
//

import SwiftUI
import UniformTypeIdentifiers

struct UploadView: View {
    @ObservedObject private var store = UploadedTracksStore.shared
    @ObservedObject private var player = PlaybackController.shared
    @State private var isImporting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if store.tracks.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                trackList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.loomBackground)
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.audio], allowsMultipleSelection: true) { result in
            if case let .success(urls) = result {
                Task { await store.add(fileURLs: urls) }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Upload")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                Text("Play your own music from this Mac")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.loomTextSecondary)
            }

            Spacer()

            addFilesButton
        }
        .padding(.horizontal, Theme.contentPadding)
        .padding(.top, Theme.contentPadding)
    }

    private var addFilesButton: some View {
        Button(action: { isImporting = true }) {
            HStack(spacing: 5) {
                Image(systemName: "plus")
                Text("Add Files")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.loomTextSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.loomSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.up.circle")
                .font(.system(size: 40))
                .foregroundStyle(Color.loomAccentBlue)
                .padding(.bottom, 4)

            Text("No music uploaded yet")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)

            Text("Add audio files from your Mac to play them here.")
                .font(.system(size: 13))
                .foregroundStyle(Color.loomTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            addFilesButton
        }
        .frame(maxWidth: 420)
    }

    private var trackList: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(store.tracks) { track in
                    trackRow(track)
                }
            }
            .padding(Theme.contentPadding)
        }
    }

    private func trackRow(_ track: UploadedTrack) -> some View {
        let isActive = player.activeLocalTrackID == track.id

        return HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.small)
                    .fill(isActive ? Color.loomAccentBlue.opacity(0.16) : Color.loomBackground)
                Image(systemName: isActive && player.isPlaying ? "waveform" : "music.note")
                    .font(.system(size: 16))
                    .foregroundStyle(isActive ? Color.loomAccentBlue : Color.loomTextSecondary)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(track.displayArtist)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.loomTextSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(track.formattedDuration)
                .font(.system(size: 12))
                .foregroundStyle(Color.loomTextSecondary)

            Button(action: { store.remove(id: track.id) }) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.loomTextSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.loomSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .stroke(isActive ? Color.loomAccentBlue : Color.loomDivider, lineWidth: isActive ? 2 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isActive {
                player.togglePlayPause()
            } else {
                player.playLocal(track, queue: store.tracks)
            }
        }
    }
}

#Preview {
    UploadView()
}
