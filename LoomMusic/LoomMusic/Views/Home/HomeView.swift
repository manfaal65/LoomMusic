//
//  HomeView.swift
//  LoomMusic
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var history = PlaybackHistoryStore.shared
    @State private var query: String = ""
    @State private var activeRequest: YouTubeMusicRequest?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.large * 1.5) {
            SearchBar(query: $query, onSubmit: performSearch, onClear: clearSearch)
                .padding(.horizontal, Theme.contentPadding)
                .padding(.top, Theme.contentPadding)

            if let activeRequest {
                YouTubeMusicPanel(request: activeRequest, onClose: clearSearch)
                    .padding(.horizontal, Theme.contentPadding)
                    .padding(.bottom, Theme.contentPadding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    RecentSection(
                        tracks: history.entries.map(\.asRecentTrack),
                        onSelect: { track in
                            activeRequest = track.historyEntry?.request
                        },
                        onDelete: { track in
                            guard let id = track.historyEntry?.id else { return }
                            history.remove(id: id)
                        }
                    )
                    .padding(Theme.contentPadding)
                }
            }
        }
        .background(Color.loomBackground)
    }

    private func performSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        history.recordSearch(query: trimmed)
        activeRequest = .search(trimmed)
    }

    private func clearSearch() {
        activeRequest = nil
    }
}

#Preview {
    HomeView()
}
