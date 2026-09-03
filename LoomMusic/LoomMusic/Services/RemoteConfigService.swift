//
//  RemoteConfigService.swift
//  LoomMusic
//

import FirebaseRemoteConfig

/// Wraps Firebase Remote Config so the Gemini API key ships via Firebase rather than
/// being hardcoded in source or entered by the user — one shared key, rotatable from
/// the Firebase Console without shipping a new build. This is convenience, not a
/// secrets vault: the key still reaches the running app and its network traffic.
final class RemoteConfigService {
    static let shared = RemoteConfigService()

    private let remoteConfig: RemoteConfig

    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings
        // Registered so the free-tier limits resolve to sane values even before
        // the first successful fetch (first launch, offline) — configValue would
        // otherwise read as 0, which would lock free users out of everything.
        remoteConfig.setDefaults([
            "free_lyrics_generation_limit": 2 as NSNumber,
            "free_song_summary_limit": 2 as NSNumber,
            "free_search_limit": 15 as NSNumber
        ])
    }

    /// Fetches and activates the latest published values. Firebase throttles actual
    /// network fetches to `minimumFetchInterval` on its own — calling this often is
    /// safe, it just re-activates the cached values within that window.
    func fetchAndActivate() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            remoteConfig.fetchAndActivate { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    var geminiAPIKey: String? {
        let value = remoteConfig.configValue(forKey: "gemini_api_key").stringValue
        return value.isEmpty ? nil : value
    }

    /// Free (non-premium) lifetime caps, tunable from the Firebase Console
    /// without a new build. `setDefaults` above covers the pre-fetch case; the
    /// `> 0` guard here covers a console value of 0/blank being published by
    /// mistake, so a feature can never be silently locked to zero uses.
    var freeLyricsGenerationLimit: Int {
        let value = remoteConfig.configValue(forKey: "free_lyrics_generation_limit").numberValue.intValue
        return value > 0 ? value : 2
    }

    var freeSongSummaryLimit: Int {
        let value = remoteConfig.configValue(forKey: "free_song_summary_limit").numberValue.intValue
        return value > 0 ? value : 2
    }

    var freeSearchLimit: Int {
        let value = remoteConfig.configValue(forKey: "free_search_limit").numberValue.intValue
        return value > 0 ? value : 15
    }
}
