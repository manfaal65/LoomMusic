//
//  AISongSummaryView.swift
//  LoomMusic
//

import SwiftUI

enum SongAnalysisState {
    case idle
    case loading
    case result(summary: SongSummary, track: OEmbedResult)
    case failed(message: String)
}

struct AISongSummaryView: View {
    @State private var trackLink: String = ""
    @State private var state: SongAnalysisState = .idle
    @State private var analysisTask: Task<Void, Never>?
    @State private var showPaywall = false
    @ObservedObject private var usage = UsageLimitStore.shared
    @ObservedObject private var store = StoreKitService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("AI Song Summary")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, Theme.contentPadding)
                .padding(.top, Theme.contentPadding)

            if case .idle = state {
                analyzeCard
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        analyzeCard
                        statusContent
                    }
                    .padding(Theme.contentPadding)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.loomBackground)
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private var subtitle: String {
        guard !store.isPremiumActive else { return "Paste a link and get key themes, structure, and mood." }
        let remaining = usage.remaining(.songSummary)
        return remaining > 0
            ? "Paste a link and get key themes, structure, and mood. · \(remaining) free left"
            : "Paste a link and get key themes, structure, and mood. · Free limit reached"
    }

    private var analyzeCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 30))
                .foregroundStyle(Color.loomAccentBlue)
                .padding(.bottom, 4)

            Text("Analyze any track")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(Color.loomTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            TextField("Paste a YouTube or SoundCloud link...", text: $trackLink)
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
                .font(.system(size: 14))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.loomBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .stroke(Color.loomDivider, lineWidth: 1)
                )
                .disabled(isLoading)
                .onSubmit {
                    guard !trackLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !isLoading else { return }
                    analyze()
                }

            Button(action: analyze) {
                Group {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Text("Analyze Track")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.loomAccentBlue)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
            }
            .buttonStyle(.plain)
            .disabled(trackLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            .opacity(trackLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        }
        .padding(32)
        .frame(width: 480)
        .background(Color.loomSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .stroke(Color.loomDivider, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var statusContent: some View {
        switch state {
        case .idle, .loading:
            EmptyView()
        case let .result(summary, track):
            resultCard(summary: summary, track: track)
        case let .failed(message):
            errorView(message)
        }
    }

    private func resultCard(summary: SongSummary, track: OEmbedResult) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                trackThumbnail(track.thumbnailURL)
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    if let authorName = track.authorName {
                        Text(authorName)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.loomTextSecondary)
                    }
                }
                Spacer()
            }

            Rectangle()
                .fill(Color.loomDivider)
                .frame(height: 1)

            if !summary.themes.isEmpty {
                summarySection(title: "Themes") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(summary.themes, id: \.self) { theme in
                                Text(theme)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.loomAccentBlue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.loomAccentBlue.opacity(0.16))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }

            summarySection(title: "Mood") {
                Text(summary.mood)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
            }

            summarySection(title: "Pacing") {
                Text(summary.pacing)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
            }

            summarySection(title: "Structure") {
                Text(summary.structureNotes)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
            }

            summarySection(title: "Summary") {
                Text(summary.summary)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.loomSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .stroke(Color.loomDivider, lineWidth: 1)
        )
    }

    private func summarySection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.loomTextSecondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func trackThumbnail(_ url: URL?) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(Color.loomBackground)
            if let url {
                AsyncImage(url: url) { phase in
                    if case let .success(image) = phase {
                        image.resizable().scaledToFill()
                    }
                }
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small))
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 22))
                .foregroundStyle(Color.loomTextSecondary)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Color.loomTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: 480)
        .padding(.top, 8)
    }

    private var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    private func analyze() {
        let trimmed = trackLink.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed) else {
            state = .failed(message: "Paste a valid YouTube or SoundCloud link.")
            return
        }
        guard usage.canUse(.songSummary) else {
            showPaywall = true
            return
        }

        analysisTask?.cancel()
        state = .loading
        analysisTask = Task {
            do {
                let track = try await OEmbedService.shared.resolve(url: url)
                guard !Task.isCancelled else { return }

                let lyricsMatches = try? await LyricsService.shared.search(query: track.title)
                let lyrics = lyricsMatches?.first?.plainLyrics

                let summary = try await GeminiService.shared.summarize(
                    title: track.title,
                    artist: track.authorName,
                    lyrics: lyrics
                )
                guard !Task.isCancelled else { return }
                state = .result(summary: summary, track: track)
                usage.recordUse(.songSummary)
            } catch is CancellationError {
                // Superseded by a newer analysis request — leave state as-is.
            } catch OEmbedServiceError.unsupportedURL {
                state = .failed(message: "Paste a valid YouTube or SoundCloud link.")
            } catch GeminiServiceError.missingAPIKey {
                state = .failed(message: "Couldn't reach the summary service right now. Please try again in a moment.")
            } catch GeminiServiceError.serverOverloaded {
                state = .failed(message: "Gemini is experiencing high demand right now. Please try again in a moment.")
            } catch let GeminiServiceError.blocked(reason) {
                state = .failed(message: "Gemini couldn't summarize this track (\(reason)). Try a different link.")
            } catch {
                state = .failed(message: "Couldn't analyze this track. Check your connection and try again.")
            }
        }
    }
}

#Preview {
    AISongSummaryView()
}
