//
//  SampleData.swift
//  LoomMusic
//

import SwiftUI

extension RecentTrack {
    static let sample: [RecentTrack] = [
        RecentTrack(
            title: "Assalam jane e alam",
            subtitle: "Beautiful Naat",
            caption: "Beautiful Salam | Assalam jaan e alam | FK TRENDING NASH...",
            thumbnail: .placeholder(symbolName: "building.2.fill", gradientColors: [Color(red: 0.10, green: 0.16, blue: 0.28), Color(red: 0.04, green: 0.05, blue: 0.09)])
        ),
        RecentTrack(
            title: "Azam Chishti Ya Nabi Salam O Laika",
            subtitle: "Live Session",
            caption: "Azam Chishti Ya Nabi Salam O Laika",
            thumbnail: .placeholder(symbolName: "music.mic", gradientColors: [Color(red: 0.16, green: 0.16, blue: 0.17), Color(red: 0.05, green: 0.05, blue: 0.05)])
        ),
        RecentTrack(
            title: "Midnight City Lights",
            subtitle: "Original Track",
            caption: "A late-night lo-fi session recorded straight to tape",
            thumbnail: .placeholder(symbolName: "waveform", gradientColors: [Color(red: 0.30, green: 0.10, blue: 0.30), Color(red: 0.06, green: 0.03, blue: 0.10)])
        ),
        RecentTrack(
            title: "Golden Hour",
            subtitle: "Acoustic Demo",
            caption: "Rough acoustic demo, guitar and vocals only",
            thumbnail: .placeholder(symbolName: "guitars.fill", gradientColors: [Color(red: 0.28, green: 0.18, blue: 0.06), Color(red: 0.08, green: 0.05, blue: 0.02)])
        )
    ]
}
