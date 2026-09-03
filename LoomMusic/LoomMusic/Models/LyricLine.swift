//
//  LyricLine.swift
//  LoomMusic
//

import Foundation

/// A single time-stamped line from an LRC-format synced lyrics file, e.g.
/// "[01:23.45]Some lyric text" -> LyricLine(time: 83.45, text: "Some lyric text").
struct LyricLine: Identifiable, Equatable {
    let id = UUID()
    let time: TimeInterval
    let text: String
}

/// Parses LRCLIB's `syncedLyrics` field (standard LRC format) into timed lines.
/// A line can carry more than one timestamp tag (repeated lyrics reusing the same
/// text), which expands into one LyricLine per tag. Non-timestamp metadata tags
/// (`[ar:Artist]`, `[ti:Title]`, `[length:03:45]`, ...) are recognized by failing
/// the numeric mm:ss parse and are dropped rather than mistaken for a lyric line.
enum LRCParser {
    nonisolated static func parse(_ raw: String) -> [LyricLine] {
        var lines: [LyricLine] = []

        for rawLine in raw.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { continue }

            var remaining = Substring(line)
            var timestamps: [TimeInterval] = []

            while remaining.hasPrefix("["), let closeIndex = remaining.firstIndex(of: "]") {
                let tag = remaining[remaining.index(after: remaining.startIndex)..<closeIndex]
                guard let time = parseTimestamp(String(tag)) else { break }
                timestamps.append(time)
                remaining = remaining[remaining.index(after: closeIndex)...]
            }

            let text = remaining.trimmingCharacters(in: .whitespaces)
            guard !timestamps.isEmpty, !text.isEmpty else { continue }

            for time in timestamps {
                lines.append(LyricLine(time: time, text: text))
            }
        }

        return lines.sorted { $0.time < $1.time }
    }

    nonisolated private static func parseTimestamp(_ tag: String) -> TimeInterval? {
        let parts = tag.split(separator: ":")
        guard parts.count == 2, let minutes = Double(parts[0]), let seconds = Double(parts[1]) else {
            return nil
        }
        return minutes * 60 + seconds
    }
}
