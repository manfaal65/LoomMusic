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
    private let storageKey = "loommusic.playbackHistory.v2"

    private init() {
        load()
    }

    func recordPlayed(track: UploadedTrack) {
        let entry = HistoryEntry(
            id: track.id.uuidString,
            trackId: track.id,
            title: track.title,
            artist: track.artist,
            fileURL: track.fileURL,
            duration: track.duration,
            timestamp: Date()
        )
        upsert(entry)
    }

    func remove(id: String) {
        entries.removeAll { $0.id == id }
        save()
    }

    func clear() {
        entries.removeAll()
        save()
    }

    private func upsert(_ entry: HistoryEntry) {
        entries.removeAll { $0.trackId == entry.trackId || $0.id == entry.id }
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
