//
//  AILyricsGeneratorView.swift
//  LoomMusic
//

import AppKit
import SwiftUI

struct AILyricsGeneratorView: View {
    private static let greeting = "Tell me a mood, genre, or story and I'll sketch a verse to get you started."

    @State private var sessionID = UUID()
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var generationTask: Task<Void, Never>?
    @State private var showHistoryPopover = false
    @ObservedObject private var chatHistory = ChatHistoryStore.shared
    @FocusState private var isComposerFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ChatBubbleView(role: .assistant, text: Self.greeting)
                            .padding(.bottom, 12)

                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            let showAvatar = index == 0 || messages[index - 1].role != message.role
                            ChatBubbleView(
                                role: message.role,
                                text: message.text,
                                showAvatar: showAvatar,
                                onCopy: message.role == .assistant ? { copy(message.text) } : nil
                            )
                            .id(message.id)
                            .padding(.top, showAvatar ? 12 : 0)
                        }

                        if isGenerating {
                            TypingIndicatorBubble()
                                .id("typing-indicator")
                                .padding(.top, 12)
                        }

                        if let errorMessage {
                            ChatBubbleView(role: .assistant, text: errorMessage)
                                .id("error")
                                .padding(.top, 12)
                        }
                    }
                    .padding(Theme.contentPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: messages.last?.id) { scrollToBottom(proxy) }
                .onChange(of: isGenerating) { scrollToBottom(proxy) }
                .onChange(of: errorMessage) { scrollToBottom(proxy) }
            }

            composer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.loomBackground)
        .onAppear { isComposerFocused = true }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Lyrics Generator")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                Text("Powered by Gemini")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.loomTextSecondary)
            }

            Spacer()

            HStack(spacing: 10) {
                Button(action: { showHistoryPopover = true }) {
                    HStack(spacing: 5) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("History")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.loomTextSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.loomSurface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showHistoryPopover, arrowEdge: .bottom) {
                    historyPopoverContent
                }

                if !messages.isEmpty {
                    Button(action: startNewChat) {
                        HStack(spacing: 5) {
                            Image(systemName: "square.and.pencil")
                            Text("New Chat")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.loomTextSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.loomSurface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
                    }
                    .buttonStyle(.plain)
                    .disabled(isGenerating)
                }
            }
        }
        .padding(.horizontal, Theme.contentPadding)
        .padding(.top, Theme.contentPadding)
    }

    private var historyPopoverContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Chats")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 8)

            if chatHistory.sessions.isEmpty {
                Text("No recent chats yet.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.loomTextSecondary)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(chatHistory.sessions) { session in
                            historyRow(session)
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.bottom, 8)
                }
                .frame(maxHeight: 320)
            }
        }
        .frame(width: 280)
        .background(Color.loomSurface)
    }

    private func historyRow(_ session: ChatSession) -> some View {
        HStack(spacing: 8) {
            Button(action: { loadSession(session) }) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(session.relativeTimestamp)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.loomTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button(action: { chatHistory.delete(id: session.id) }) {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.loomTextSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(session.id == sessionID ? Color.loomAccentBlue.opacity(0.12) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small))
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Describe a mood, genre, or story...", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
                .font(.system(size: 14))
                .lineLimit(1...6)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.loomSurface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.pill)
                        .stroke(Color.loomDivider, lineWidth: 1)
                )
                .disabled(isGenerating)
                .focused($isComposerFocused)
                .onKeyPress(phases: .down) { press in
                    guard press.key == .return, !press.modifiers.contains(.shift) else { return .ignored }
                    send()
                    return .handled
                }

            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(canSend ? Color.loomAccentBlue : Color.loomTextSecondary.opacity(0.4))
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
        }
        .padding(Theme.contentPadding)
    }

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            if errorMessage != nil {
                proxy.scrollTo("error", anchor: .bottom)
            } else if isGenerating {
                proxy.scrollTo("typing-indicator", anchor: .bottom)
            } else if let lastID = messages.last?.id {
                proxy.scrollTo(lastID, anchor: .bottom)
            }
        }
    }

    private func copy(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    private func startNewChat() {
        generationTask?.cancel()
        generationTask = nil
        sessionID = UUID()
        messages = []
        errorMessage = nil
        isGenerating = false
        inputText = ""
        isComposerFocused = true
    }

    private func loadSession(_ session: ChatSession) {
        generationTask?.cancel()
        generationTask = nil
        sessionID = session.id
        messages = session.messages
        errorMessage = nil
        isGenerating = false
        inputText = ""
        showHistoryPopover = false
        isComposerFocused = true
    }

    private func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isGenerating else { return }

        messages.append(ChatMessage(role: .user, text: trimmed))
        inputText = ""
        errorMessage = nil
        isGenerating = true

        generationTask?.cancel()
        generationTask = Task {
            let history = messages
            do {
                let reply = try await GeminiService.shared.generateLyrics(history: history)
                guard !Task.isCancelled else { return }
                messages.append(ChatMessage(role: .assistant, text: reply))
                chatHistory.save(id: sessionID, messages: messages)
            } catch is CancellationError {
                // Superseded by a newer send — leave state as-is.
            } catch GeminiServiceError.missingAPIKey {
                errorMessage = "Couldn't reach the lyrics generator right now. Please try again in a moment."
            } catch GeminiServiceError.serverOverloaded {
                errorMessage = "Gemini is experiencing high demand right now. Please try again in a moment."
            } catch let GeminiServiceError.blocked(reason) {
                errorMessage = "Gemini couldn't generate that (\(reason)). Try rephrasing your idea."
            } catch {
                errorMessage = "Couldn't generate lyrics right now. Check your connection and try again."
            }
            isGenerating = false
        }
    }
}

#Preview {
    AILyricsGeneratorView()
}
