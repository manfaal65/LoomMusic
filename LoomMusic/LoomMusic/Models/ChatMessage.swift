//
//  ChatMessage.swift
//  LoomMusic
//

import Foundation

struct ChatMessage: Identifiable, Equatable, Codable {
    enum Role: Codable {
        case user
        case assistant
    }

    let id: UUID
    let role: Role
    let text: String

    init(id: UUID = UUID(), role: Role, text: String) {
        self.id = id
        self.role = role
        self.text = text
    }
}
