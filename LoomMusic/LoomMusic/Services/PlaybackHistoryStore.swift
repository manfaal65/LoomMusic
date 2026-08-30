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
