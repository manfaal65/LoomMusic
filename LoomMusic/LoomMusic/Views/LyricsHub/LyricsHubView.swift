//
//  LyricsHubView.swift
//  LoomMusic
//

import SwiftUI

enum SongSearchState: Equatable {
    case idle
    case loading
    case empty(query: String)
    case failed(query: String)
}

struct LyricsHubView: View {
    @State private var songs: [Song] = Song.sample
    @State private var selectedSong: Song? = Song.sample.first
    @State private var searchState: SongSearchState = .idle
    @State private var searchTask: Task<Void, Never>?
    @State private var showPaywall = false
    @ObservedObject private var usage = UsageLimitStore.shared

    var body: some View {
        HStack(spacing: 0) {
            SongListPane(
                songs: songs,
                selectedSong: $selectedSong,
                searchState: searchState,
                onSubmitSearch: performSearch,
                onClearSearch: resetToSample
            )

            if let selectedSong {
                SongDetailPane(song: selectedSong)
                    .id(selectedSong.id)
            } else {
                emptyDetailState
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.loomBackground)
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private var emptyDetailState: some View {
        VStack(spacing: 8) {
            Image(systemName: "music.note")
                .font(.system(size: 28))
                .foregroundStyle(Color.loomTextSecondary)
            Text("Search for a song to see its lyrics")
                .font(.system(size: 14))
                .foregroundStyle(Color.loomTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.loomBackground)
    }

    private func performSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            resetToSample()
            return
        }
        guard usage.canUse(.search) else {
            showPaywall = true
            return
        }
        usage.recordUse(.search)

        searchTask?.cancel()
        searchState = .loading
        searchTask = Task {
            do {
                let results = try await LyricsService.shared.search(query: trimmed)
                guard !Task.isCancelled else { return }
                let mapped = results.map(Song.init(lrcTrack:))
                songs = mapped
                selectedSong = mapped.first
                searchState = mapped.isEmpty ? .empty(query: trimmed) : .idle
            } catch {
                guard !Task.isCancelled else { return }
                searchState = .failed(query: trimmed)
            }
        }
    }

    private func resetToSample() {
        searchTask?.cancel()
        songs = Song.sample
        selectedSong = Song.sample.first
        searchState = .idle
    }
}

#Preview {
    LyricsHubView()
}
