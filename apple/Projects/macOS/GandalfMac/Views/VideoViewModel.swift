import SwiftUI
import AVFoundation
import os.log
import GandalfSync

@MainActor
class VideoViewModel: ObservableObject {
    @Published var isInitialized = false
    @Published var syncSource: NtpClient.SyncSource = .deviceClock

    let player = AVQueuePlayer()
    private var playerLooper: AVPlayerLooper?
    private var ntpClient = NtpClient()
    private var isFirstSync = true
    private var resyncTimer: Timer?
    private var videoDurationMicros: Int64 = 0

    private let logger = Logger(subsystem: "com.onemdev.gandalf", category: "VideoViewModel")

    func initialize() {
        logger.info("initialize() called")

        guard let url = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
            logger.error("ERROR: video.mp4 not found in bundle")
            // List bundle resources for debugging
            if let urls = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) {
                logger.error("Found mp4 files: \(urls)")
            }
            return
        }

        logger.info("Video URL: \(url.path)")

        let item = AVPlayerItem(url: url)
        player.insert(item, after: nil)

        // Wait for the item to be ready, then set up looper + sync
        Task {
            // Wait for the item status to become readyToPlay
            let status = (try? await item.asset.load(.isReadable)) ?? false
            logger.info("Asset readable: \(status)")

            let duration = try? await item.asset.load(.duration)
            let durationSecs = CMTimeGetSeconds(duration ?? .zero)
            videoDurationMicros = Int64(durationSecs * 1_000_000)
            logger.info("Video duration: \(durationSecs)s (\(self.videoDurationMicros)µs)")

            // Set up looper now that we have the item loaded
            playerLooper = AVPlayerLooper(player: player, templateItem: item)

            isInitialized = true
            logger.info("Player initialized, starting NTP sync...")

            await performSync()
            player.play()
            logger.info("Playback started")
            startResyncTimer()
        }
    }

    func pause() {
        player.pause()
    }

    func syncVideo() {
        Task {
            await performSync()
            player.play()
        }
    }

    private func performSync() async {
        logger.info("Performing NTP sync...")
        let result = await ntpClient.sync()
        syncSource = result.source
        logger.info("NTP result: offset=\(result.offsetMicros)µs, source=\(result.source.rawValue)")

        guard videoDurationMicros > 0 else {
            logger.warning("Video duration is 0, skipping seek")
            return
        }

        let seconds = SyncCalculator.seekSeconds(
            ntpOffsetMicros: result.offsetMicros,
            videoDurationMicros: videoDurationMicros,
            isFirstSync: isFirstSync
        )

        let time = CMTime(seconds: seconds, preferredTimescale: 1_000_000)
        logger.info("Seeking to \(seconds)s")
        await player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)

        isFirstSync = false
    }

    private func startResyncTimer() {
        resyncTimer?.invalidate()
        resyncTimer = Timer.scheduledTimer(withTimeInterval: NtpClient.resyncIntervalSeconds, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.performSync()
            }
        }
    }

    deinit {
        resyncTimer?.invalidate()
    }
}
