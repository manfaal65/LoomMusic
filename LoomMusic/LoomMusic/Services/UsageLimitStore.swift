//
//  UsageLimitStore.swift
//  LoomMusic
//

import Combine
import Foundation

enum FreeFeature {
    case lyricsGeneration
    case songSummary
    case search
}

/// Tracks how many times a non-premium user has used each rate-limited free
/// feature. Premium users (StoreKitService.shared.isPremiumActive) are always
/// unlimited and never consume from these counters. Limits are remote-
/// configurable (RemoteConfigService) so they can be tuned without a new
/// build; usage counts persist locally as a lifetime cap, not a per-period
/// allowance — there's no reset schedule today, only going premium lifts it.
final class UsageLimitStore: ObservableObject {
    static let shared = UsageLimitStore()

    @Published private(set) var lyricsGenerationsUsed: Int
    @Published private(set) var songSummariesUsed: Int
    @Published private(set) var searchesUsed: Int

    private let lyricsKey = "loommusic.usage.lyricsGenerations"
    private let summaryKey = "loommusic.usage.songSummaries"
    private let searchKey = "loommusic.usage.searches"

    private init() {
        let defaults = UserDefaults.standard
        lyricsGenerationsUsed = defaults.integer(forKey: lyricsKey)
        songSummariesUsed = defaults.integer(forKey: summaryKey)
        searchesUsed = defaults.integer(forKey: searchKey)
    }

    var lyricsGenerationLimit: Int { RemoteConfigService.shared.freeLyricsGenerationLimit }
    var songSummaryLimit: Int { RemoteConfigService.shared.freeSongSummaryLimit }
    var searchLimit: Int { RemoteConfigService.shared.freeSearchLimit }

    /// Whether this action is allowed right now — premium users always are;
    /// free users are as long as they're under the remote-configured limit.
    func canUse(_ feature: FreeFeature) -> Bool {
        guard !StoreKitService.shared.isPremiumActive else { return true }
        switch feature {
        case .lyricsGeneration: return lyricsGenerationsUsed < lyricsGenerationLimit
        case .songSummary: return songSummariesUsed < songSummaryLimit
        case .search: return searchesUsed < searchLimit
        }
    }

    /// Records one use. For lyrics generation and song summaries, call this
    /// only once the AI call actually succeeded — a failed/errored attempt
    /// shouldn't burn the user's quota. Search records on every attempted
    /// query regardless of result count, since the query itself is the cost.
    func recordUse(_ feature: FreeFeature) {
        guard !StoreKitService.shared.isPremiumActive else { return }
        let defaults = UserDefaults.standard
        switch feature {
        case .lyricsGeneration:
            lyricsGenerationsUsed += 1
            defaults.set(lyricsGenerationsUsed, forKey: lyricsKey)
        case .songSummary:
            songSummariesUsed += 1
            defaults.set(songSummariesUsed, forKey: summaryKey)
        case .search:
            searchesUsed += 1
            defaults.set(searchesUsed, forKey: searchKey)
        }
    }

    func remaining(_ feature: FreeFeature) -> Int {
        switch feature {
        case .lyricsGeneration: return max(0, lyricsGenerationLimit - lyricsGenerationsUsed)
        case .songSummary: return max(0, songSummaryLimit - songSummariesUsed)
        case .search: return max(0, searchLimit - searchesUsed)
        }
    }
}
