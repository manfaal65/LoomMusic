//
//  OEmbedService.swift
//  LoomMusic
//

import Foundation

struct OEmbedResult {
    let title: String
    let authorName: String?
    let thumbnailURL: URL?
}

enum OEmbedServiceError: Error {
    case unsupportedURL
    case invalidResponse
}

/// Resolves a pasted YouTube/SoundCloud link to a title/artist/thumbnail via
/// each platform's official, keyless oEmbed endpoint. Also intelligently handles
/// search query URLs, YouTube Music URLs, and YouTube Shorts.
final class OEmbedService {
    static let shared = OEmbedService()

    private init() {}

    func resolve(url: URL) async throws -> OEmbedResult {
        // 1. If user pasted a YouTube search results URL, extract query and resolve via lyrics/song lookup
        if let host = url.host?.lowercased(), host.contains("youtube.com") || host.contains("youtu.be") {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let searchItem = components.queryItems?.first(where: { $0.name == "search_query" })?.value,
               !searchItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let query = searchItem.replacingOccurrences(of: "+", with: " ")
                if let matches = try? await LyricsService.shared.search(query: query), let first = matches.first {
                    return OEmbedResult(
                        title: first.trackName,
                        authorName: first.artistName,
                        thumbnailURL: nil
                    )
                } else {
                    return OEmbedResult(
                        title: query,
                        authorName: nil,
                        thumbnailURL: nil
                    )
                }
            }
        }

        // 2. Normalize music.youtube.com -> www.youtube.com and /shorts/ -> /watch?v=
        let normalized = Self.normalizedURL(for: url)

        guard let endpoint = Self.oEmbedEndpoint(for: normalized) else {
            throw OEmbedServiceError.unsupportedURL
        }

        let (data, response) = try await URLSession.shared.data(from: endpoint)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw OEmbedServiceError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(RawResponse.self, from: data)
        return OEmbedResult(
            title: decoded.title,
            authorName: decoded.authorName,
            thumbnailURL: decoded.thumbnailURL.flatMap(URL.init(string:))
        )
    }

    private static func normalizedURL(for url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        guard let host = components.host?.lowercased() else { return url }

        // YouTube's oEmbed endpoint rejects music.youtube.com host, normalize to www.youtube.com
        if host == "music.youtube.com" {
            components.host = "www.youtube.com"
        }

        // Normalize YouTube Shorts to /watch?v=
        if components.path.hasPrefix("/shorts/") {
            let videoId = components.path.replacingOccurrences(of: "/shorts/", with: "")
            components.path = "/watch"
            components.queryItems = [URLQueryItem(name: "v", value: videoId)]
        }

        return components.url ?? url
    }

    private static func oEmbedEndpoint(for url: URL) -> URL? {
        guard let host = url.host?.lowercased() else { return nil }

        let base: String
        if host.contains("youtube.com") || host.contains("youtu.be") {
            base = "https://www.youtube.com/oembed"
        } else if host.contains("soundcloud.com") {
            base = "https://soundcloud.com/oembed"
        } else {
            return nil
        }

        var components = URLComponents(string: base)!
        components.queryItems = [
            URLQueryItem(name: "url", value: url.absoluteString),
            URLQueryItem(name: "format", value: "json")
        ]
        return components.url
    }

    private struct RawResponse: Decodable {
        let title: String
        let authorName: String?
        let thumbnailURL: String?

        enum CodingKeys: String, CodingKey {
            case title
            case authorName = "author_name"
            case thumbnailURL = "thumbnail_url"
        }
    }
}
