//
//  HistoryEntry.swift
//  LoomMusic
//

import SwiftUI

struct HistoryEntry: Codable, Identifiable, Equatable {
    enum Kind: Codable, Equatable {
        case searched(query: String, thumbnailURL: URL? = nil)
        case played(videoId: String, title: String, thumbnailURL: URL?)
    }

    let id: String
    var kind: Kind
    var timestamp: Date

    var displayTitle: String {
        switch kind {
        case let .searched(query, _):
            return query
        case let .played(_, title, _):
            return title
        }
    }

    var displaySubtitle: String {
        switch kind {
        case .searched:
            return "Searched"
        case .played:
            return "Played on YouTube Music"
        }
    }

    var thumbnailURL: URL? {
        switch kind {
        case let .searched(_, url):
            return url
        case let .played(_, _, url):
            return url
        }
    }

    var request: YouTubeMusicRequest {
        switch kind {
        case let .searched(query, _):
            return .search(query)
        case let .played(videoId, _, _):
            return .watch(videoId: videoId)
        }
    }
}

extension HistoryEntry {
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    var asRecentTrack: RecentTrack {
        let thumbnail: Thumbnail
        if let thumbnailURL {
            thumbnail = .remote(thumbnailURL)
        } else {
            thumbnail = .placeholder(symbolName: "magnifyingglass", gradientColors: [Color.loomAccentBlue, Color.loomAccentEnd])
        }

        return RecentTrack(
            title: displayTitle,
            subtitle: displaySubtitle,
            caption: Self.relativeFormatter.localizedString(for: timestamp, relativeTo: Date()),
            thumbnail: thumbnail,
            historyEntry: self
        )
    }
}
