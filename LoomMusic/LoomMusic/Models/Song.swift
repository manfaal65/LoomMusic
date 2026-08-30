//
//  Song.swift
//  LoomMusic
//

import SwiftUI

struct SongInfo {
    let album: String
    let year: String
    let genre: String
    let duration: String
    let writer: String
    let producer: String
    let label: String
}

struct Song: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let year: String
    let duration: String
    let genre: String
    let artColors: [Color]
    let lyrics: [String]
    let info: SongInfo
}
