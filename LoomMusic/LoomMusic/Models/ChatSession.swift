//
//  ChatSession.swift
//  LoomMusic
//

import Foundation

struct ChatSession: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    var updatedAt: Date
}

extension ChatSession {
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    var relativeTimestamp: String {
        Self.relativeFormatter.localizedString(for: updatedAt, relativeTo: Date())
    }
}
