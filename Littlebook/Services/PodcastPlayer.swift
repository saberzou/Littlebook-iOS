import Foundation
import AVFoundation
import MediaPlayer
import Combine

/// Streams a pre-generated AI podcast episode using AVPlayer.
/// Integrates with the iOS lock screen and Control Center via MPNowPlayingInfoCenter
/// and responds to headphone / CarPlay hardware commands via MPRemoteCommandCenter.
///
/// Lifecycle:
///   • Created once as a @StateObject in LittlebookApp and injected via @EnvironmentObject.
///   • Call load(podcast:book:) to begin streaming a new episode.
///   • Audio continues playing when the app is backgrounded (requires UIBackgroundModes:audio in Info.plist).
@MainActor
final class PodcastPlayer: ObservableObject {

    // MARK: - Playback State

    enum PlaybackState: Equatable {
        case idle
        case loading
        case playing
        case paused
        case finished
        case error(String)

        var isActive: Bool {
            switch self {
            case .playing, .paused, .finished: return true
            default: return false
            }
        }
    }

    // MARK: - Published State (drives all UI)

    @Published var state: PlaybackState = .idle
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isBuffering: Bool = false
    @Published var currentPodcast: Podcast?
    @Published var currentBook: Book?

    // MARK: - Private

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init / Deinit

    init() {
        configureAudioSession()
        configureRemoteCommands()
    }

    deinit {
        if let obs = timeObserver { player?.removeTimeObserver(obs) }
    }

    // MARK: - Public API

    /// Load and immediately begin streaming the given podcast episode.
    /// Calling this while another episode is playing will stop the current episode first.
    func load(podcast: Podcast, book: Book) {
        guard let url = podcast.resolvedAudioURL else {
            state = .error("Invalid audio URL")
            return
        }

        teardown()
        currentPodcast = podcast
        currentBook = book
        state = .loading
        isBuffering = true
        // Pre-seed duration from JSON so the progress bar renders before AVPlayer reports it
        duration = TimeInterval(podcast.duration)

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.automaticallyWaitsToMinimizeStalling = true

        observeItemStatus(item: item, podcast: podcast, book: book)
        observeBuffering(item: item)
        observeEndOfEpisode(item: item)
        addPeriodicTimeObserver()
    }

    func togglePlayPause() {
        switch state {
        case .playing:
            player?.pause()
            state = .paused
            updateNowPlayingRate(0)
        case .paused:
            player?.play()
            state = .playing
            updateNowPlayingRate(1)
        case .finished:
            seek(to: 0)
            player?.play()
            state = .playing
            updateNowPlayingRate(1)
        default:
            break
        }
    }

    func seek(to time: TimeInterval) {
        let clamped = max(0, min(time, duration))
        let target = CMTime(seconds: clamped, preferredTimescale: 600)
        player?.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.currentTime = clamped
                self?.updateNowPlayingElapsed()
            }
        }
    }

    func skip(by seconds: TimeInterval) {
        seek(to: currentTime + seconds)
    }

    func stop() {
        teardown()
    }

    // MARK: - Private: Observers

    private func observeItemStatus(item: AVPlayerItem, podcast: Podcast, book: Book) {
        item.publisher(for: \.status)
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    let actual = item.duration.seconds
                    if !actual.isNaN && actual > 0 { self.duration = actual }
                    self.isBuffering = false
                    self.state = .playing
                    self.player?.play()
                    self.updateNowPlayingInfo(book: book)
                case .failed:
                    self.isBuffering = false
                    self.state = .error(item.error?.localizedDescription ?? "Playback failed")
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func observeBuffering(item: AVPlayerItem) {
        item.publisher(for: \.isPlaybackLikelyToKeepUp)
            .receive(on: RunLoop.main)
            .sink { [weak self] likely in
                guard let self else { return }
                self.isBuffering = !likely && self.state == .playing
            }
            .store(in: &cancellables)
    }

    private func observeEndOfEpisode(item: AVPlayerItem) {
        NotificationCenter.default.publisher(
            for: AVPlayerItem.didPlayToEndTimeNotification,
            object: item
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in
            guard let self else { return }
            self.state = .finished
            self.currentTime = self.duration
            self.updateNowPlayingRate(0)
        }
        .store(in: &cancellables)
    }

    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            // Hop to MainActor to safely access @MainActor-isolated properties
            Task { @MainActor [weak self] in
                guard let self, self.state == .playing else { return }
                self.currentTime = time.seconds
            }
        }
    }

    private func teardown() {
        if let obs = timeObserver { player?.removeTimeObserver(obs) }
        timeObserver = nil
        cancellables.removeAll()
        player?.pause()
        player = nil
        currentTime = 0
        duration = 0
        state = .idle
        isBuffering = false
        currentPodcast = nil
        currentBook = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    // MARK: - Private: Audio Session

    private func configureAudioSession() {
        do {
            // .spokenAudio mode causes other audio (e.g. music) to duck when Littlebook plays.
            // This is the standard behavior for podcasts and audiobooks on iOS.
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .spokenAudio,
                options: []
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[PodcastPlayer] Audio session error: \(error)")
        }
    }

    // MARK: - Private: Lock Screen / Control Center

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        center.skipForwardCommand.preferredIntervals = [15]
        center.skipForwardCommand.addTarget { [weak self] _ in
            self?.skip(by: 15)
            return .success
        }
        center.skipBackwardCommand.preferredIntervals = [15]
        center.skipBackwardCommand.addTarget { [weak self] _ in
            self?.skip(by: -15)
            return .success
        }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let e = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(to: e.positionTime)
            return .success
        }
    }

    private func updateNowPlayingInfo(book: Book) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: "AI Podcast: \(book.title)",
            MPMediaItemPropertyArtist: book.author,
            MPMediaItemPropertyAlbumTitle: "Littlebook Daily",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
        ]
    }

    private func updateNowPlayingElapsed() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func updateNowPlayingRate(_ rate: Double) {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyPlaybackRate] = rate
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
