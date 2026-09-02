//
//  PlaybackController.swift
//  LoomMusic
//

import AVFoundation
import Combine
import WebKit

/// Bridges playback state to the app's bottom PlayerBar from either of two
/// sources — the embedded YouTube Music WKWebView (via JS injection) or a
/// locally uploaded audio file (via AVAudioPlayer) — so the same bar/controls
/// work regardless of where the audio is coming from. Only one source plays
/// at a time; starting one stops the other.
final class PlaybackController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = PlaybackController()

    @Published private(set) var isConnected = false
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var title: String = "Not Playing"
    @Published private(set) var artist: String = "Select a song to begin"
    @Published private(set) var artworkURL: URL?
    @Published private(set) var activeLocalTrackID: UUID?

    private weak var activeWebView: WKWebView?

    private var audioPlayer: AVAudioPlayer?
    private var localQueue: [UploadedTrack] = []
    private var localIndex: Int = 0
    private var progressTimer: Timer?

    private override init() {}

    // MARK: - YouTube Music (WebView) source

    func attach(_ webView: WKWebView) {
        stopLocalPlayback()
        activeWebView = webView
        isConnected = true
    }

    func detach(_ webView: WKWebView) {
        guard activeWebView === webView else { return }
        activeWebView = nil
        reset()
    }

    func updateFromBridge(isPlaying: Bool, currentTime: TimeInterval, duration: TimeInterval, title: String, artist: String, artworkURL: URL?) {
        guard audioPlayer == nil else { return }
        self.isPlaying = isPlaying
        self.currentTime = currentTime
        self.duration = duration
        if !title.isEmpty { self.title = title }
        if !artist.isEmpty { self.artist = artist }
        if let artworkURL { self.artworkURL = artworkURL }
    }

    // MARK: - Local (uploaded file) source

    func playLocal(_ track: UploadedTrack, queue: [UploadedTrack]) {
        run("document.querySelector('video')?.pause();")
        localQueue = queue
        localIndex = queue.firstIndex(of: track) ?? 0
        startLocalPlayback(track)
    }

    func stopLocal() {
        guard audioPlayer != nil else { return }
        reset()
    }

    private func startLocalPlayback(_ track: UploadedTrack) {
        stopLocalPlayback()

        guard let player = try? AVAudioPlayer(contentsOf: track.fileURL) else { return }
        player.delegate = self
        player.play()
        audioPlayer = player

        isConnected = true
        isPlaying = true
        currentTime = 0
        duration = player.duration
        title = track.title
        artist = track.displayArtist
        artworkURL = nil
        activeLocalTrackID = track.id

        startProgressTimer()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.advanceLocalQueue()
        }
    }

    private func advanceLocalQueue() {
        let nextIndex = localIndex + 1
        guard nextIndex < localQueue.count else {
            reset()
            return
        }
        localIndex = nextIndex
        startLocalPlayback(localQueue[nextIndex])
    }

    private func retreatLocalQueue() {
        let previousIndex = localIndex - 1
        guard previousIndex >= 0 else { return }
        localIndex = previousIndex
        startLocalPlayback(localQueue[previousIndex])
    }

    private func stopLocalPlayback() {
        progressTimer?.invalidate()
        progressTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil
    }

    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        }
    }

    // MARK: - Shared transport controls

    func togglePlayPause() {
        if let audioPlayer {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                isPlaying = false
                progressTimer?.invalidate()
            } else {
                audioPlayer.play()
                isPlaying = true
                startProgressTimer()
            }
        } else {
            run("document.querySelector('#play-pause-button')?.click();")
        }
    }

    func skipNext() {
        if audioPlayer != nil {
            advanceLocalQueue()
        } else {
            run("document.querySelector('.next-button')?.click();")
        }
    }

    func skipPrevious() {
        if audioPlayer != nil {
            retreatLocalQueue()
        } else {
            run("document.querySelector('.previous-button')?.click();")
        }
    }

    func seek(toFraction fraction: Double) {
        let clamped = max(0, min(1, fraction))
        if let audioPlayer {
            audioPlayer.currentTime = audioPlayer.duration * clamped
            currentTime = audioPlayer.currentTime
        } else {
            run("var v = document.querySelector('video'); if (v && isFinite(v.duration)) { v.currentTime = v.duration * \(clamped); }")
        }
    }

    private func reset() {
        stopLocalPlayback()
        localQueue = []
        localIndex = 0
        isConnected = false
        isPlaying = false
        currentTime = 0
        duration = 0
        title = "Not Playing"
        artist = "Select a song to begin"
        artworkURL = nil
        activeLocalTrackID = nil
    }

    private func run(_ script: String) {
        activeWebView?.evaluateJavaScript(script)
    }
}
