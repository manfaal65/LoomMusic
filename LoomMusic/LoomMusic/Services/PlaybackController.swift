//
//  PlaybackController.swift
//  LoomMusic
//

import AVFoundation
import Combine
import Foundation

/// Central audio playback controller powered by AVFoundation.
/// Manages playback of user-uploaded local audio files, transport controls,
/// queue progression, and synchronizes with PlaybackHistoryStore.
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
    @Published var volume: Float = 0.8 {
        didSet {
            audioPlayer?.volume = volume
        }
    }

    private var audioPlayer: AVAudioPlayer?
    private var localQueue: [UploadedTrack] = []
    private var localIndex: Int = 0
    private var progressTimer: Timer?

    private override init() {
        super.init()
    }

    // MARK: - Playback Commands

    func playLocal(_ track: UploadedTrack, queue: [UploadedTrack]) {
        localQueue = queue.isEmpty ? [track] : queue
        localIndex = localQueue.firstIndex(of: track) ?? 0
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
        player.volume = volume
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

        PlaybackHistoryStore.shared.recordPlayed(track: track)
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

    // MARK: - Transport Controls

    func togglePlayPause() {
        guard let audioPlayer else { return }
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            isPlaying = false
            progressTimer?.invalidate()
        } else {
            audioPlayer.play()
            isPlaying = true
            startProgressTimer()
        }
    }

    func skipNext() {
        advanceLocalQueue()
    }

    func skipPrevious() {
        if let audioPlayer, audioPlayer.currentTime > 3.0 {
            audioPlayer.currentTime = 0
            currentTime = 0
        } else {
            retreatLocalQueue()
        }
    }

    func seek(toFraction fraction: Double) {
        let clamped = max(0, min(1, fraction))
        guard let audioPlayer else { return }
        audioPlayer.currentTime = audioPlayer.duration * clamped
        currentTime = audioPlayer.currentTime
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
}
