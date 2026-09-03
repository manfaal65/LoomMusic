//
//  SyncedLyricsView.swift
//  LoomMusic
//

import SwiftUI

/// Spotify-style lyrics: the line whose timestamp has most recently passed is
/// highlighted. Deliberately has no ScrollView of its own — it's always hosted
/// inside SongDetailPane's single outer ScrollView, and nesting a second
/// same-axis ScrollView here would collapse to zero height (no way to compute
/// an intrinsic size), rendering nothing during playback. Auto-scroll-to-active-
/// line is driven by the outer ScrollViewReader instead, keyed off each line's id.
struct SyncedLyricsView: View {
    let lines: [LyricLine]
    let activeLineID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(lines) { line in
                let isActive = line.id == activeLineID
                Text(line.text)
                    .font(.system(size: isActive ? 20 : 16, weight: isActive ? .bold : .regular))
                    .foregroundStyle(isActive ? .white : Color.loomTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .id(line.id)
                    .animation(.easeInOut(duration: 0.2), value: activeLineID)
            }
        }
        .padding(.vertical, 24)
    }
}

#Preview {
    let lines = [
        LyricLine(time: 0, text: "First line of the song"),
        LyricLine(time: 3, text: "Second line comes in here"),
        LyricLine(time: 6, text: "And the chorus follows after")
    ]
    ScrollView {
        SyncedLyricsView(lines: lines, activeLineID: lines[1].id)
            .padding()
    }
    .background(Color.loomBackground)
}
