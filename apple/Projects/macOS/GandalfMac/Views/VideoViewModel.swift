import SwiftUI
import AVFoundation
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

    func initialize() {
        guard let url = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
            print("ERROR: video.mp4 not found in bundle")
            return
        }

        let item = AVPlayerItem(url: url)
        playerLooper = AVPlayerLooper(player: player, templateItem: item)

        Task {
            let duration = try? await item.asset.load(.duration)
            let durationSecs = CMTimeGetSeconds(duration ?? .zero)
            videoDurationMicros = Int64(durationSecs * 1_000_000)

            isInitialized = true
            await performSync()
            player.play()
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
        let result = await ntpClient.sync()
        syncSource = result.source

        guard videoDurationMicros > 0 else { return }

        let seconds = SyncCalculator.seekSeconds(
            ntpOffsetMicros: result.offsetMicros,
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
                await self?.performSync()
            }
        }
    }

    deinit {
        resyncTimer?.invalidate()
    }
}
