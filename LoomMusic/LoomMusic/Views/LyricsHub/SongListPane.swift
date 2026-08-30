//
//  SongListPane.swift
//  LoomMusic
//

import SwiftUI

struct SongListPane: View {
    @Binding var selectedSong: Song
    @State private var query: String = ""

    private var filteredSongs: [Song] {
        guard !query.isEmpty else { return Song.sample }
        return Song.sample.filter {
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
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.loomSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.pill)
                    .stroke(Color.loomDivider, lineWidth: 1)
            )

            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(filteredSongs) { song in
                        SongListRow(song: song, isSelected: song.id == selectedSong.id) {
                            selectedSong = song
                        }
                    }
                }
            }
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
}

#Preview {
    SongListPane(selectedSong: .constant(Song.sample[0]))
        .background(Color.loomBackground)
}
