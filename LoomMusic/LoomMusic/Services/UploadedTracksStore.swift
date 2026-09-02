//
//  UploadedTracksStore.swift
//  LoomMusic
//

import AVFoundation
import Combine
import Foundation

/// Persists locally-uploaded audio files (title/artist/duration + file URL) so
/// the Upload tab's library survives relaunches. The app runs with
/// ENABLE_APP_SANDBOX = NO, so plain file URLs remain valid across launches
/// without security-scoped bookmarks.
final class UploadedTracksStore: ObservableObject {
    static let shared = UploadedTracksStore()

    @Published private(set) var tracks: [UploadedTrack] = []

    private let storageKey = "loommusic.uploadedTracks"

    private init() {
        load()
    }

    func add(fileURLs: [URL]) async {
        var newTracks: [UploadedTrack] = []
        for url in fileURLs {
            guard !tracks.contains(where: { $0.fileURL == url }) else { continue }
            newTracks.append(await Self.makeTrack(from: url))
        }
        guard !newTracks.isEmpty else { return }
        tracks.insert(contentsOf: newTracks, at: 0)
        persist()
    }

    func remove(id: UUID) {
        if PlaybackController.shared.activeLocalTrackID == id {
            PlaybackController.shared.stopLocal()
        }
        tracks.removeAll { $0.id == id }
        persist()
    }

    private static func makeTrack(from url: URL) async -> UploadedTrack {
        let asset = AVURLAsset(url: url)
        let fallbackTitle = url.deletingPathExtension().lastPathComponent

        var title = fallbackTitle
        var artist: String?
        var duration: TimeInterval = 0

        if let metadata = try? await asset.load(.commonMetadata) {
            for item in metadata {
                guard let key = item.commonKey else { continue }
                if key == .commonKeyTitle, let value = try? await item.load(.stringValue), !value.isEmpty {
                    title = value
                } else if key == .commonKeyArtist, let value = try? await item.load(.stringValue), !value.isEmpty {
                    artist = value
                }
            }
        }
        if let loadedDuration = try? await asset.load(.duration) {
            duration = loadedDuration.seconds
        }

        return UploadedTrack(id: UUID(), title: title, artist: artist, fileURL: url, duration: duration, addedAt: Date())
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        tracks = (try? JSONDecoder().decode([UploadedTrack].self, from: data)) ?? []
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(tracks) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
