import Foundation

/// Calculates the global-synced video seek position.
///
/// seekPosition = (syncedTime + elapsed) % duration + buffer
/// where elapsed = currentDeviceTime - localReferenceTime
public struct SyncCalculator {

    /// Calculate seek position in microseconds.
    ///
    /// - Parameters:
    ///   - syncedTimeMicros: The server-synced reference time in microseconds
    ///   - localReferenceMicros: The local device time (in microseconds) captured at the moment of sync
    ///   - videoDurationMicros: Video duration in microseconds
    ///   - isFirstSync: Whether this is the first sync (uses larger buffer)
    /// - Returns: Seek position in microseconds
    public static func seekPosition(
        syncedTimeMicros: Int64,
        localReferenceMicros: Int64,
        videoDurationMicros: Int64,
        isFirstSync: Bool
    ) -> Int64 {
        let currentDeviceMicros = Int64(NSDate().timeIntervalSince1970 * 1_000_000)
        let elapsedMicros = currentDeviceMicros - localReferenceMicros
        let currentSyncedTime = syncedTimeMicros + elapsedMicros
        let buffer = isFirstSync ? NtpClient.bufferFirstSyncMicros : NtpClient.bufferMicros
        var raw = (currentSyncedTime % videoDurationMicros) + buffer
        if raw >= videoDurationMicros {
            raw -= videoDurationMicros
        }
        return raw
    }

    /// Calculate seek position as seconds (for AVPlayer/CMTime).
    public static func seekSeconds(
        syncedTimeMicros: Int64,
        localReferenceMicros: Int64,
        videoDurationMicros: Int64,
        isFirstSync: Bool
    ) -> Double {
        let micros = seekPosition(
            syncedTimeMicros: syncedTimeMicros,
            localReferenceMicros: localReferenceMicros,
            videoDurationMicros: videoDurationMicros,
            isFirstSync: isFirstSync
        )
        return Double(micros) / 1_000_000.0
    }
}
