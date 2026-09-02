//
//  PlaybackController.swift
//  LoomMusic
//

import Combine
import WebKit

/// Bridges the embedded YouTube Music WKWebView's playback state to the app's
/// bottom PlayerBar. The webview only exists while the panel is open on Home
/// (see YouTubeMusicWebView's attach/detach calls), so PlayerBar reflects
/// "Not Playing" whenever nothing is attached.
final class PlaybackController: ObservableObject {
    static let shared = PlaybackController()

    @Published private(set) var isConnected = false
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var title: String = "Not Playing"
    @Published private(set) var artist: String = "Select a song to begin"
    @Published private(set) var artworkURL: URL?

    private weak var activeWebView: WKWebView?

    private init() {}

    func attach(_ webView: WKWebView) {
        activeWebView = webView
        isConnected = true
    }

    func detach(_ webView: WKWebView) {
        guard activeWebView === webView else { return }
        activeWebView = nil
        reset()
    }

    func updateFromBridge(isPlaying: Bool, currentTime: TimeInterval, duration: TimeInterval, title: String, artist: String, artworkURL: URL?) {
        self.isPlaying = isPlaying
        self.currentTime = currentTime
        self.duration = duration
        if !title.isEmpty { self.title = title }
        if !artist.isEmpty { self.artist = artist }
        if let artworkURL { self.artworkURL = artworkURL }
    }

    func togglePlayPause() {
        run("document.querySelector('#play-pause-button')?.click();")
    }

    func skipNext() {
        run("document.querySelector('.next-button')?.click();")
    }

    func skipPrevious() {
        run("document.querySelector('.previous-button')?.click();")
    }

    func seek(toFraction fraction: Double) {
        let clamped = max(0, min(1, fraction))
        run("var v = document.querySelector('video'); if (v && isFinite(v.duration)) { v.currentTime = v.duration * \(clamped); }")
    }

    private func reset() {
        isConnected = false
        isPlaying = false
        currentTime = 0
        duration = 0
        title = "Not Playing"
        artist = "Select a song to begin"
        artworkURL = nil
    }

    private func run(_ script: String) {
        activeWebView?.evaluateJavaScript(script)
    }
}
