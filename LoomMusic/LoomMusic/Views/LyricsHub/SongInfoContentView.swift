//
//  SongInfoContentView.swift
//  LoomMusic
//

import SwiftUI

struct SongInfoContentView: View {
    let info: SongInfo

    private var rows: [(String, String)] {
        [
            ("Album", info.album),
            ("Year", info.year),
            ("Genre", info.genre),
            ("Duration", info.duration),
            ("Writer", info.writer),
            ("Producer", info.producer),
            ("Label", info.label)
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows, id: \.0) { label, value in
                HStack {
                    Text(label)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.loomTextSecondary)
                    Spacer()
                    Text(value)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 14)

                if label != rows.last?.0 {
                    Rectangle()
                        .fill(Color.loomDivider)
                        .frame(height: 1)
                }
            }
        }
    }
}

#Preview {
    SongInfoContentView(info: Song.sample[0].info)
        .padding()
        .background(Color.loomBackground)
}
