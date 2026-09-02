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
}
