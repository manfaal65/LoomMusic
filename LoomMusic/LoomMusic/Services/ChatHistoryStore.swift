//
//  ChatHistoryStore.swift
//  LoomMusic
//

import Combine
import Foundation

/// Persists AI Lyrics Generator conversations locally so recent chats can be
/// reopened from the "History" button. Follows the same UserDefaults+Codable
/// pattern as PlaybackHistoryStore.
final class ChatHistoryStore: ObservableObject {
    static let shared = ChatHistoryStore()

    @Published private(set) var sessions: [ChatSession] = []

    private let maxSessions = 30
    private let storageKey = "loommusic.lyricsChatHistory"

    private init() {
        load()
    }

    /// Creates or updates the session with the given id — called after each
    /// completed turn so an in-progress conversation stays saved as it grows,
    /// rather than only on some explicit "save" action. No-ops if there's no
    /// user message yet (nothing worth remembering).
    func save(id: UUID, messages: [ChatMessage]) {
        guard let firstUserMessage = messages.first(where: { $0.role == .user }) else { return }

        let title = String(firstUserMessage.text.prefix(60))
        let session = ChatSession(id: id, title: title, messages: messages, updatedAt: Date())

        sessions.removeAll { $0.id == id }
        sessions.insert(session, at: 0)
        if sessions.count > maxSessions {
            sessions.removeLast(sessions.count - maxSessions)
        }
        persist()
    }

    func delete(id: UUID) {
        sessions.removeAll { $0.id == id }
        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        sessions = (try? JSONDecoder().decode([ChatSession].self, from: data)) ?? []
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
