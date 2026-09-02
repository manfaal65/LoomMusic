//
//  LyricsService.swift
//  LoomMusic
//

import Foundation

/// A single search result from LRCLIB — a free, keyless, crowdsourced lyrics API
/// (https://lrclib.net). LRCLIB is lyrics-focused: it has no reliable year/genre/
/// writer/producer/label fields, only track/artist/album/duration and the lyrics
/// themselves, so those richer metadata fields are left unavailable ("—") when a
/// song comes from here rather than the bundled sample set.
struct LRCLIBTrack: Decodable {
    let id: Int
    let trackName: String
    let artistName: String
    let albumName: String?
    let duration: Double?
    let instrumental: Bool?
    let plainLyrics: String?
    let syncedLyrics: String?
}

enum LyricsServiceError: Error {
    case invalidResponse
}

final class LyricsService {
    static let shared = LyricsService()

    private init() {}

    func search(query: String) async throws -> [LRCLIBTrack] {
        var components = URLComponents(string: "https://lrclib.net/api/search")!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        guard let url = components.url else { throw LyricsServiceError.invalidResponse }

        var request = URLRequest(url: url)
        // LRCLIB asks API consumers to identify their app via User-Agent.
        request.setValue("LoomMusic/1.0 (macOS)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw LyricsServiceError.invalidResponse
        }
        return try JSONDecoder().decode([LRCLIBTrack].self, from: data)
    }
}
