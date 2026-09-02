//
//  NavTab.swift
//  LoomMusic
//

import Foundation

enum NavTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case lyricsHub = "Lyrics Hub"
    case aiLyricsGenerator = "AI Lyrics Generator"
    case aiSongSummary = "AI Song Summary"
    case upload = "Upload"

    var id: Self { self }

    var symbolName: String {
        switch self {
        case .home: return "house"
        case .lyricsHub: return "text.quote"
        case .aiLyricsGenerator: return "sparkles"
        case .aiSongSummary: return "doc.text.magnifyingglass"
        case .upload: return "arrow.up.circle"
        }
    }
}
