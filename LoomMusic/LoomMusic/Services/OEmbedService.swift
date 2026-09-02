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
/// each platform's official, keyless oEmbed endpoint — no download, no API key,
/// same "let the platform do the work" approach used for the YouTube Music webview.
final class OEmbedService {
    static let shared = OEmbedService()

    private init() {}

    func resolve(url: URL) async throws -> OEmbedResult {
        guard let endpoint = Self.oEmbedEndpoint(for: url) else {
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
