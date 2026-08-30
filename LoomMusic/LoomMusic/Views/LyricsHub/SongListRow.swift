//
//  SongListRow.swift
//  LoomMusic
//

import SwiftUI

struct SongListRow: View {
    let song: Song
    let isSelected: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                LatticePattern(colors: song.artColors)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(song.artist)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.loomTextSecondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(10)
            .background(isSelected ? Color.loomSurface : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 6) {
        SongListRow(song: Song.sample[0], isSelected: true)
        SongListRow(song: Song.sample[1], isSelected: false)
    }
    .padding()
    .background(Color.loomBackground)
}
