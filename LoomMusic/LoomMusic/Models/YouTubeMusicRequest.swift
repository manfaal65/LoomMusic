//
//  YouTubeMusicRequest.swift
//  LoomMusic
//

import Foundation

enum YouTubeMusicRequest: Equatable, Codable {
    case search(String)
    case watch(videoId: String)

    var url: URL {
        switch self {
        case let .search(query):
            var components = URLComponents(string: "https://music.youtube.com/search")!
            components.queryItems = [URLQueryItem(name: "q", value: query)]
            return components.url!
        case let .watch(videoId):
            return URL(string: "https://music.youtube.com/watch?v=\(videoId)")!
        }
    }
}
