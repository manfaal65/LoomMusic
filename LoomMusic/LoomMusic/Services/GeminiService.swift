//
//  GeminiService.swift
//  LoomMusic
//

import Foundation

struct SongSummary: Decodable, Equatable {
    let themes: [String]
    let mood: String
    let pacing: String
    let structureNotes: String
    let summary: String
}

enum GeminiServiceError: Error {
    case missingAPIKey
    case invalidResponse
    case blocked(reason: String)
    case serverOverloaded
}

/// Calls Google's Gemini `generateContent` REST endpoint directly — there's no
/// official Gemini Swift SDK, so this mirrors the raw-URLSession approach already
/// used by LyricsService for LRCLIB. Endpoint/model/request shape confirmed against
/// Google's live docs (ai.google.dev) rather than assumed from training data, since
/// the Gemini API has moved past what older references describe.
final class GeminiService {
    static let shared = GeminiService()

    private init() {}

    private static let model = "gemini-3.8-flash"
    private static let endpoint = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!

    // MARK: - AI Song Summary

    func summarize(title: String, artist: String?, lyrics: String?) async throws -> SongSummary {
        let text = try await generateText(
            systemInstruction: Self.summarySystemInstruction,
            contents: [(.user, Self.buildSummaryPrompt(title: title, artist: artist, lyrics: lyrics))],
            temperature: 0.4
        )

        guard let jsonData = Self.stripCodeFence(from: text).data(using: .utf8) else {
            throw GeminiServiceError.invalidResponse
        }
        return try JSONDecoder().decode(SongSummary.self, from: jsonData)
    }

    private static let summarySystemInstruction = """
    You analyze song lyrics for a music app. Given a track's title, artist, and lyrics \
    (lyrics may be unavailable), respond with ONLY a single JSON object — no prose, no \
    code fences — matching exactly this shape:
    {
      "themes": ["short theme", "short theme", ...],
      "mood": "one short phrase describing the emotional tone",
      "pacing": "one short phrase describing the song's apparent energy/tempo feel, e.g. 'upbeat, driving energy' or 'slow, reflective ballad' — this is an impression from the lyrics/context, not a measured tempo, so never state a specific BPM number or claim it was measured from audio",
      "structureNotes": "a brief, clearly best-effort read of the song's structure inferred from repeated lines/sections in the lyrics (e.g. verse/chorus pattern) — explicitly note if lyrics weren't available to infer this from",
      "summary": "2-4 sentence narrative summary of what the song is about"
    }
    If lyrics are not provided, base everything on the title and artist alone and say so \
    plainly in structureNotes and summary rather than inventing content.
    """

    private static func buildSummaryPrompt(title: String, artist: String?, lyrics: String?) -> String {
        var lines = ["Title: \(title)"]
        if let artist, !artist.isEmpty {
            lines.append("Artist: \(artist)")
        }
        if let lyrics, !lyrics.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("Lyrics:\n\(lyrics)")
        } else {
            lines.append("Lyrics: not available")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - AI Lyrics Generator

    func generateLyrics(history: [ChatMessage]) async throws -> String {
        let contents: [(GeminiRole, String)] = history.map { message in
            (message.role == .user ? .user : .model, message.text)
        }
        return try await generateText(
            systemInstruction: Self.lyricsSystemInstruction,
            contents: contents,
            temperature: 0.75
        )
    }

    private static let lyricsSystemInstruction = """
    You are LyricLoom AI, an expert songwriter embedded in a music app's chat-based \
    lyrics generator. Your only job is to write excellent, original song lyrics from \
    whatever the user gives you — a mood, genre, story, specific images, names, or even \
    just a single word.

    HOW TO USE WHAT THE USER GIVES YOU
    - Mine every detail they mention (genre, mood, tempo/energy, era or artist influences, \
    specific people/places/objects, a story beat, a repeated phrase they want) and work \
    it concretely into the lyrics — named details should show up as actual imagery or \
    lines, not be summarized away into generic filler.
    - Never ask a clarifying question and never refuse to start. If the request is sparse \
    (e.g. just "sad song" or "hip hop"), make confident creative choices yourself and \
    write the full thing anyway — treat vagueness as creative freedom, not a blocker.
    - Match the genre's real conventions: rap gets rhythm and internal rhyme, country gets \
    narrative and plainspoken imagery, pop gets a hooky, repeatable chorus, ballads get \
    space and simpler rhyme. Don't write generic verse for every genre.

    CRAFT STANDARDS (this is what "good" means here)
    - Use concrete, sensory imagery and specific details over abstract statements. Prefer \
    "headlights on a wet exit ramp" to "I feel so alone."
    - Keep a consistent rhyme scheme within each section (e.g. ABAB or AABB) and reasonably \
    even line lengths/syllable counts so it's actually singable — don't let lines balloon \
    or shrink at random.
    - The chorus must be the most quotable, compact part of the song and should feel \
    distinct from the verses in rhythm, not just repeat verse phrasing.
    - No clichés or filler lines that only exist to hit a rhyme (no "roses are red" style \
    padding). Every line should earn its place.

    STRUCTURE AND OUTPUT FORMAT
    - By default, write a complete song: Verse 1, Chorus, Verse 2, Chorus, and a Bridge if \
    it earns its place, then a final Chorus — not just a single sketch verse — unless the \
    user explicitly asks for something shorter (e.g. "just one verse" or "a quick hook").
    - Label each section on its own line exactly like this: "Verse 1", "Chorus", "Verse 2", \
    "Bridge", "Outro" — plain text, no colon, no brackets, no markdown symbols (never use \
    **, #, *, or - for formatting; this is rendered as plain text, not markdown).
    - Leave one blank line between sections and use a plain line break between each lyric \
    line within a section.
    - Do not add any commentary, preamble, or explanation before or after the lyrics — \
    output the song itself and nothing else, so the whole reply is usable as-is.

    REVISIONS
    - If a message is a follow-up asking for a change (e.g. "make it sadder," "add a \
    bridge," "shorten the chorus," "make verse 2 about her leaving instead"), revise the \
    existing song rather than starting over, and always return the FULL updated song again \
    (every section, not just the changed part) so the chat always shows the current \
    complete version. Only start something entirely new if the user clearly asks for a \
    different song.
    """

    // MARK: - Shared low-level call

    private enum GeminiRole: String {
        case user
        case model
    }

    private func generateText(
        systemInstruction: String,
        contents: [(GeminiRole, String)],
        temperature: Double
    ) async throws -> String {
        try? await RemoteConfigService.shared.fetchAndActivate()
        guard let apiKey = RemoteConfigService.shared.geminiAPIKey, !apiKey.isEmpty else {
            throw GeminiServiceError.missingAPIKey
        }

        let body: [String: Any] = [
            "contents": contents.map { role, text in
                ["role": role.rawValue, "parts": [["text": text]]]
            },
            "systemInstruction": [
                "parts": [["text": systemInstruction]]
            ],
            "generationConfig": [
                "maxOutputTokens": 2048,
                "temperature": temperature
            ]
        ]
        let httpBody = try JSONSerialization.data(withJSONObject: body)

        // Gemini occasionally returns a transient 503 "high demand" error —
        // Google's own message says spikes are usually short-lived, so retry
        // once after a brief delay before surfacing it to the user.
        var lastError: Error = GeminiServiceError.invalidResponse
        for attempt in 0..<2 {
            if attempt > 0 {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
            }
            do {
                return try await Self.performRequest(apiKey: apiKey, httpBody: httpBody)
            } catch GeminiServiceError.serverOverloaded {
                lastError = GeminiServiceError.serverOverloaded
            }
        }
        throw lastError
    }

    private static func performRequest(apiKey: String, httpBody: Data) async throws -> String {
        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.httpBody = httpBody

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw GeminiServiceError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 503 {
                throw GeminiServiceError.serverOverloaded
            }
            throw GeminiServiceError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(GenerateContentResponse.self, from: data)
        guard let candidate = decoded.candidates?.first else {
            throw GeminiServiceError.invalidResponse
        }
        if let finishReason = candidate.finishReason, finishReason != "STOP" {
            throw GeminiServiceError.blocked(reason: finishReason)
        }
        guard let text = candidate.content?.parts?.first?.text else {
            throw GeminiServiceError.invalidResponse
        }
        return text
    }

    private static func stripCodeFence(from text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard result.hasPrefix("```") else { return result }

        if let firstNewline = result.firstIndex(of: "\n") {
            result = String(result[result.index(after: firstNewline)...])
        }
        if let range = result.range(of: "```", options: .backwards) {
            result = String(result[..<range.lowerBound])
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private struct GenerateContentResponse: Decodable {
        let candidates: [Candidate]?

        struct Candidate: Decodable {
            let content: Content?
            let finishReason: String?
        }

        struct Content: Decodable {
            let parts: [Part]?
        }

        struct Part: Decodable {
            let text: String?
        }
    }
}
