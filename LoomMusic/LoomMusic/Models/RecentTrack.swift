//
//  RecentTrack.swift
//  LoomMusic
//

import SwiftUI

enum Thumbnail {
    case placeholder(symbolName: String, gradientColors: [Color])
}

struct RecentTrack: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let caption: String
    let thumbnail: Thumbnail
}
