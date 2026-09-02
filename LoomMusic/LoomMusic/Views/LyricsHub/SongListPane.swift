//
//  SongListPane.swift
//  LoomMusic
//

import SwiftUI

struct SongListPane: View {
    let songs: [Song]
    @Binding var selectedSong: Song?
    let searchState: SongSearchState
    var onSubmitSearch: (String) -> Void = { _ in }
    var onClearSearch: () -> Void = {}

    @State private var query: String = ""

    private var filteredSongs: [Song] {
        guard !query.isEmpty else { return songs }
        return songs.filter {
            $0.title.localizedCaseInsensitiveContains(query) || $0.artist.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.loomTextSecondary)
                TextField("Search by song or artist...", text: $query)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                    .font(.system(size: 14))
                    .onSubmit { onSubmitSearch(query) }

                if !query.isEmpty {
                    Button {
                        query = ""
                        onClearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.loomTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.loomSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.pill)
                    .stroke(Color.loomDivider, lineWidth: 1)
            )

            content
        }
        .padding(Theme.Spacing.large)
        .frame(width: 340)
        .background(Color.loomBackground)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.loomDivider)
                .frame(width: 1)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch searchState {
        case .loading:
            statusView(symbol: "arrow.triangle.2.circlepath", message: "Searching lyrics…")
        case let .empty(query):
            statusView(symbol: "questionmark.circle", message: "No lyrics found for \"\(query)\".")
        case let .failed(query):
            statusView(symbol: "exclamationmark.triangle", message: "Couldn't load lyrics for \"\(query)\". Check your connection and try again.")
        case .idle:
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(filteredSongs) { song in
                        SongListRow(song: song, isSelected: song.id == selectedSong?.id) {
                            selectedSong = song
                        }
                    }
                }
            }
        }
    }

    private func statusView(symbol: String, message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 22))
                .foregroundStyle(Color.loomTextSecondary)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Color.loomTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}

#Preview {
    SongListPane(songs: Song.sample, selectedSong: .constant(Song.sample[0]), searchState: .idle)
        .background(Color.loomBackground)
}
