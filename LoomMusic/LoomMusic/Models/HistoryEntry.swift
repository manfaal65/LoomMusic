//
//  HistoryEntry.swift
//  LoomMusic
//

import SwiftUI

struct HistoryEntry: Codable, Identifiable, Equatable {
    let id: String
    let trackId: UUID
    let title: String
    let artist: String?
    let fileURL: URL
    let duration: TimeInterval
    var timestamp: Date

    var displayTitle: String {
        title
    }

    var displaySubtitle: String {
        artist ?? "Local Audio"
    }

    var asUploadedTrack: UploadedTrack {
        UploadedTrack(
            id: trackId,
            title: title,
            artist: artist,
            fileURL: fileURL,
            duration: duration,
            addedAt: timestamp
        )
    }
}

extension HistoryEntry {
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    var asRecentTrack: RecentTrack {
        RecentTrack(
            title: displayTitle,
            subtitle: displaySubtitle,
            caption: Self.relativeFormatter.localizedString(for: timestamp, relativeTo: Date()),
            thumbnail: .placeholder(
                symbolName: "music.note",
                gradientColors: [Color.loomAccentBlue, Color.loomAccentEnd]
            ),
            historyEntry: self
        )
    }
}
