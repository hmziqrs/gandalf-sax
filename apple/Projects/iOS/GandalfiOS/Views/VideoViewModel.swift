import SwiftUI
import AVFoundation
import GandalfShared

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

    // Stored sync reference state
    private var syncedTimeMicros: Int64 = 0
    private var localReferenceMicros: Int64 = 0

    func initialize() {
        guard let url = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
            print("ERROR: video.mp4 not found in bundle")
            return
        }

        let item = AVPlayerItem(url: url)
        playerLooper = AVPlayerLooper(player: player, templateItem: item)

        // Observe when the item is ready
        Task {
            // Wait for the item to be ready to play
            _ = try? await item.asset.load(.duration)

            let duration = try? await item.asset.load(.duration)
            let durationSecs = CMTimeGetSeconds(duration ?? .zero)
            videoDurationMicros = Int64(durationSecs * 1_000_000)

            isInitialized = true

            // Initial NTP sync
            await performSync()
            player.play()

            // Start periodic re-sync
            startResyncTimer()
        }
    }

    func pause() {
        player.pause()
    }

    func syncVideo() {
        Task {
            if syncedTimeMicros == 0 {
                // No stored reference yet — fall back to full sync
                await performSync()
            } else {
                // Use stored reference to calculate seek position without re-syncing
                guard videoDurationMicros > 0 else { return }

                let seconds = SyncCalculator.seekSeconds(
                    syncedTimeMicros: syncedTimeMicros,
                    localReferenceMicros: localReferenceMicros,
                    videoDurationMicros: videoDurationMicros,
                    isFirstSync: false
                )

                let time = CMTime(seconds: seconds, preferredTimescale: 1_000_000)
                await player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            }
            player.play()
        }
    }

    private func performSync() async {
        let result = await ntpClient.sync()
        syncSource = result.source

        // Store sync reference values
        syncedTimeMicros = result.syncedTimeMicros
        localReferenceMicros = result.localReferenceMicros

        guard videoDurationMicros > 0 else { return }

        let seconds = SyncCalculator.seekSeconds(
            syncedTimeMicros: syncedTimeMicros,
            localReferenceMicros: localReferenceMicros,
            videoDurationMicros: videoDurationMicros,
            isFirstSync: isFirstSync
        )

        let time = CMTime(seconds: seconds, preferredTimescale: 1_000_000)
        await player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)

        isFirstSync = false
    }

    private func startResyncTimer() {
        resyncTimer?.invalidate()
        resyncTimer = Timer.scheduledTimer(withTimeInterval: NtpClient.resyncIntervalSeconds, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.performSync()
            }
        }
    }

    deinit {
        resyncTimer?.invalidate()
    }
}
