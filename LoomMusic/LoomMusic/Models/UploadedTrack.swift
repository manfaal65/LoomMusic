//
//  UploadedTrack.swift
//  LoomMusic
//

import Foundation

struct UploadedTrack: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var artist: String?
    var fileURL: URL
    var duration: TimeInterval
    var addedAt: Date
}

extension UploadedTrack {
    var displayArtist: String {
        artist ?? "Unknown Artist"
    }

    var formattedDuration: String {
        guard duration.isFinite, duration >= 0 else { return "0:00" }
        let total = Int(duration)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
