//
//  LyricsHubView.swift
//  LoomMusic
//

import SwiftUI

struct LyricsHubView: View {
    @State private var selectedSong: Song = Song.sample[0]

    var body: some View {
        HStack(spacing: 0) {
            SongListPane(selectedSong: $selectedSong)
            SongDetailPane(song: selectedSong)
                .id(selectedSong.id)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.loomBackground)
    }
}

#Preview {
    LyricsHubView()
}
