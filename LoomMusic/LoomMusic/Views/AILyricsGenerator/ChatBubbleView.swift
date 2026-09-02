//
//  ChatBubbleView.swift
//  LoomMusic
//

import SwiftUI

struct ChatBubbleView: View {
    let role: ChatMessage.Role
    let text: String
    var showAvatar: Bool = true
    var onCopy: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if role == .user {
                Spacer(minLength: 60)
            } else {
                avatar.opacity(showAvatar ? 1 : 0)
            }

            VStack(alignment: role == .user ? .trailing : .leading, spacing: 6) {
                bubbleContent

                if role == .assistant, let onCopy {
                    Button(action: onCopy) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy")
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.loomTextSecondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 4)
                }
            }
            .frame(maxWidth: 560, alignment: role == .user ? .trailing : .leading)

            if role == .assistant {
                Spacer(minLength: 60)
            }
        }
        .frame(maxWidth: .infinity, alignment: role == .user ? .trailing : .leading)
    }

    private var bubbleContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                if line.isEmpty {
                    Color.clear.frame(height: 6)
                } else if role == .assistant && Self.isSectionLabel(line) {
                    Text(line.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(Color.loomAccentBlue)
                        .padding(.top, 2)
                } else {
                    Text(line)
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(role == .user ? Color.loomAccentBlue : Color.loomSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var lines: [String] {
        text.components(separatedBy: "\n")
    }

    /// Matches the plain-text section labels the Gemini prompt is instructed to emit
    /// (e.g. "Verse 1", "Chorus", "Bridge") so they can be styled instead of shown as
    /// an ordinary lyric line.
    private static func isSectionLabel(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.count <= 20 else { return false }
        let pattern = #"^(verse\s*\d*|pre-?chorus|chorus|bridge|outro|intro|hook)$"#
        return trimmed.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private var avatar: some View {
        ZStack {
            Circle().fill(Color.loomAccentBlue.opacity(0.18))
            Image(systemName: "music.note")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.loomAccentBlue)
        }
        .frame(width: 28, height: 28)
    }
}

struct TypingIndicatorBubble: View {
    @State private var animate = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle().fill(Color.loomAccentBlue.opacity(0.18))
                Image(systemName: "music.note")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.loomAccentBlue)
            }
            .frame(width: 28, height: 28)

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.loomTextSecondary)
                        .frame(width: 6, height: 6)
                        .opacity(animate ? 1 : 0.3)
                        .animation(
                            .easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2),
                            value: animate
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.loomSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { animate = true }
    }
}

#Preview {
    VStack(spacing: 12) {
        ChatBubbleView(role: .assistant, text: "Tell me a mood, genre, or story and I'll sketch a verse to get you started.")
        ChatBubbleView(role: .user, text: "A bittersweet indie-folk song about leaving your hometown.", showAvatar: false)
        ChatBubbleView(
            role: .assistant,
            text: "Verse 1\nPorch light fading in the mirror\nGravel road still holding on\n\nChorus\nI'm leaving with the dust behind me\nCarrying this town till it's gone",
            onCopy: {}
        )
        TypingIndicatorBubble()
    }
    .padding()
    .background(Color.loomBackground)
}
