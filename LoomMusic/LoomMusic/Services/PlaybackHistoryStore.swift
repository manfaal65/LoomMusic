//
//  PlaybackHistoryStore.swift
//  LoomMusic
//

import Combine
import Foundation

final class PlaybackHistoryStore: ObservableObject {
    static let shared = PlaybackHistoryStore()

    @Published private(set) var entries: [HistoryEntry] = []

    private let maxEntries = 24
    private let storageKey = "loommusic.playbackHistory"

    private init() {
        load()
    }

    func recordSearch(query: String) {
        upsert(HistoryEntry(id: query, kind: .searched(query: query), timestamp: Date()))
    }

    func recordPlayed(videoId: String, title: String, thumbnailURL: URL?) {
        upsert(HistoryEntry(id: videoId, kind: .played(videoId: videoId, title: title, thumbnailURL: thumbnailURL), timestamp: Date()))
    }

    /// Fills in a real thumbnail scraped from the embedded search results page for an
    /// already-recorded search entry, without disturbing its position or timestamp.
    func updateSearchThumbnail(query: String, thumbnailURL: URL) {
        guard let index = entries.firstIndex(where: { $0.id == query }) else { return }
        guard case .searched(let existingQuery, let existingThumbnail) = entries[index].kind, existingThumbnail == nil else { return }
        entries[index].kind = .searched(query: existingQuery, thumbnailURL: thumbnailURL)
        save()
    }

    func remove(id: String) {
        entries.removeAll { $0.id == id }
        save()
    }

    private func upsert(_ entry: HistoryEntry) {
        entries.removeAll { $0.id == entry.id }
        entries.insert(entry, at: 0)
        if entries.count > maxEntries {
            entries.removeLast(entries.count - maxEntries)
        }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        entries = (try? JSONDecoder().decode([HistoryEntry].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
