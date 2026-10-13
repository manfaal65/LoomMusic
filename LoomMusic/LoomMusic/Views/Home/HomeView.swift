//
//  HomeView.swift
//  LoomMusic
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @ObservedObject private var history = PlaybackHistoryStore.shared
    @ObservedObject private var uploadedStore = UploadedTracksStore.shared
    @ObservedObject private var player = PlaybackController.shared
    @State private var query: String = ""
    @State private var isImporting = false

    private var filteredTracks: [UploadedTrack] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return [] }
        return uploadedStore.tracks.filter { track in
            track.title.lowercased().contains(trimmed) ||
            track.displayArtist.lowercased().contains(trimmed)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.large) {
            topControls
                .padding(.horizontal, Theme.contentPadding)
                .padding(.top, Theme.contentPadding)

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.large * 1.5) {
                    if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        searchResultsSection
                    } else if history.entries.isEmpty && uploadedStore.tracks.isEmpty {
                        welcomeEmptyState
                    } else {
                        if !history.entries.isEmpty {
                            RecentSection(
                                tracks: history.entries.map(\.asRecentTrack),
                                onSelect: { track in
                                    if let entry = track.historyEntry {
                                        playEntry(entry)
                                    }
                                },
                                onDelete: { track in
                                    guard let id = track.historyEntry?.id else { return }
                                    history.remove(id: id)
                                }
                            )
                        }

                        if !uploadedStore.tracks.isEmpty {
                            librarySection
                        }
                    }
                }
                .padding(.horizontal, Theme.contentPadding)
                .padding(.bottom, Theme.contentPadding)
            }
        }
        .background(Color.loomBackground)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true
        ) { result in
            if case let .success(urls) = result {
                Task { await uploadedStore.add(fileURLs: urls) }
            }
        }
    }

    private var topControls: some View {
        HStack(spacing: Theme.Spacing.medium) {
            SearchBar(
                query: $query,
                onSubmit: {},
                onClear: { query = "" }
            )

            Button(action: { isImporting = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                    Text("Add Audio")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(Color.loomAccentBlue)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
            }
            .buttonStyle(.plain)
        }
    }

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeader(title: "Search Results (\(filteredTracks.count))")

            Rectangle()
                .fill(Color.loomDivider)
                .frame(height: 1)

            if filteredTracks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.loomTextSecondary)
                    Text("No local tracks match \"\(query)\"")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.loomTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 8) {
                    ForEach(filteredTracks) { track in
                        trackRow(track, queue: filteredTracks)
                    }
                }
            }
        }
    }

    private var librarySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeader(title: "Your Tracks (\(uploadedStore.tracks.count))")

            Rectangle()
                .fill(Color.loomDivider)
                .frame(height: 1)

            VStack(spacing: 8) {
                ForEach(uploadedStore.tracks) { track in
                    trackRow(track, queue: uploadedStore.tracks)
                }
            }
        }
    }

    private func trackRow(_ track: UploadedTrack, queue: [UploadedTrack]) -> some View {
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

            Button(action: { uploadedStore.remove(id: track.id) }) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.loomTextSecondary)
            }
            .buttonStyle(.plain)
            .help("Delete from library")
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
                player.playLocal(track, queue: queue)
            }
        }
    }

    private var welcomeEmptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "music.note.house")
                .font(.system(size: 48))
                .foregroundStyle(Color.loomAccentBlue)
                .padding(.bottom, 4)

            Text("Welcome to YuTunes")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            Text("Add audio files from your Mac to build your music library.\nEnjoy offline, high-quality audio playback anytime.")
                .font(.system(size: 13))
                .foregroundStyle(Color.loomTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 8)

            Button(action: { isImporting = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Add Audio Files")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.loomAccentBlue)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: 480)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func playEntry(_ entry: HistoryEntry) {
        let track = uploadedStore.tracks.first(where: { $0.id == entry.trackId || $0.fileURL == entry.fileURL }) ?? entry.asUploadedTrack
        let queue = uploadedStore.tracks.isEmpty ? [track] : uploadedStore.tracks
        player.playLocal(track, queue: queue)
    }
}

#Preview {
    HomeView()
}
