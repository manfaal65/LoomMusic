//
//  YouTubeMusicRequest.swift
//  LoomMusic
//

import Foundation

enum YouTubeMusicRequest: Equatable, Codable {
    case search(String)
    case watch(videoId: String)

    var searchQuery: String? {
        if case let .search(query) = self { return query }
        return nil
    }

    var url: URL {
        switch self {
        case let .search(query):
            return Self.url(path: "/search", queryName: "q", queryValue: query)
        case let .watch(videoId):
            return Self.url(path: "/watch", queryName: "v", queryValue: videoId)
        }
    }

    // Builds via URLComponents/URLQueryItem so the query value is always properly
    // percent-encoded, instead of raw string interpolation into a URL string — a
    // videoId or search query containing characters invalid in that position could
    // otherwise produce a nil URL and crash a force-unwrap.
    private static func url(path: String, queryName: String, queryValue: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "music.youtube.com"
        components.path = path
        components.queryItems = [URLQueryItem(name: queryName, value: queryValue)]
        return components.url ?? URL(string: "https://music.youtube.com\(path)")!
    }
}
