//
//  Song.swift
//  LoomMusic
//

import SwiftUI

struct SongInfo {
    let album: String
    let year: String
    let genre: String
    let duration: String
    let writer: String
    let producer: String
    let label: String
}

struct Song: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let year: String
    let duration: String
    let genre: String
    let artColors: [Color]
    let lyrics: [String]
    let info: SongInfo
}

extension Song {
    private static let placeholderPalette: [[Color]] = [
        [Color(red: 0.35, green: 0.62, blue: 0.82), Color(red: 0.10, green: 0.24, blue: 0.40)],
        [Color(red: 0.62, green: 0.24, blue: 0.44), Color(red: 0.22, green: 0.08, blue: 0.18)],
        [Color(red: 0.20, green: 0.24, blue: 0.42), Color(red: 0.06, green: 0.07, blue: 0.16)],
        [Color(red: 0.78, green: 0.52, blue: 0.20), Color(red: 0.30, green: 0.18, blue: 0.05)],
        [Color(red: 0.16, green: 0.46, blue: 0.34), Color(red: 0.05, green: 0.15, blue: 0.11)],
        [Color(red: 0.70, green: 0.20, blue: 0.24), Color(red: 0.24, green: 0.06, blue: 0.08)]
    ]

    /// LRCLIB only ever supplies track/artist/album/duration/lyrics, so the richer
    /// SongInfo fields (year, genre, writer, producer, label) are unavailable for a
    /// searched track and shown as "—" rather than left blank or guessed.
    init(lrcTrack track: LRCLIBTrack) {
        let durationText = Self.formattedDuration(track.duration)
        let album = (track.albumName?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 } ?? "—"

        self.init(
            title: track.trackName,
            artist: track.artistName,
            year: "—",
            duration: durationText,
            genre: "—",
            artColors: Self.placeholderPalette[abs(track.artistName.hashValue) % Self.placeholderPalette.count],
            lyrics: Self.paragraphs(from: track.plainLyrics, instrumental: track.instrumental ?? false),
            info: SongInfo(album: album, year: "—", genre: "—", duration: durationText, writer: "—", producer: "—", label: "—")
        )
    }

    private static func paragraphs(from plainLyrics: String?, instrumental: Bool) -> [String] {
        if instrumental {
            return ["This track is instrumental — no lyrics to show."]
        }
        guard let plainLyrics, !plainLyrics.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ["Lyrics aren't available for this track yet."]
        }
        let blocks = plainLyrics
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return blocks.isEmpty ? [plainLyrics] : blocks
    }

    private static func formattedDuration(_ seconds: Double?) -> String {
        guard let seconds, seconds > 0 else { return "—" }
        let total = Int(seconds)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
