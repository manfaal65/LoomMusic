//
//  SongDetailPane.swift
//  LoomMusic
//

import SwiftUI

struct SongDetailPane: View {
    let song: Song
    @State private var selectedTab: SongDetailTab = .lyrics

    var body: some View {
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

                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Preview")
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
                    LyricsContentView(paragraphs: song.lyrics)
                case .songInfo:
                    SongInfoContentView(info: song.info)
                }
            }
            .padding(Theme.Spacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.loomBackground)
    }
}

#Preview {
    SongDetailPane(song: Song.sample[0])
}
