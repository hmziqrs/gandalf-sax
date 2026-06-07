import Foundation
import Network
import os.log

/// NTP client that queries multiple servers and computes a median offset
/// between device time and true NTP time.
public actor NtpClient {

    // MARK: - Types

    public enum SyncSource: String, Sendable {
        case ntp = "NTP"
        case deviceClock = "Device Clock"
    }

    public struct SyncResult: Sendable {
        public let offsetMicros: Int64
        public let source: SyncSource
        /// NTP-corrected "true time" = localReferenceMicros + offsetMicros
        public let syncedTimeMicros: Int64
        /// Local device time snapshot taken right after NTP queries complete
        public let localReferenceMicros: Int64
    }

    // MARK: - Constants

    private static let ntpServers = [
        "time.google.com",
        "time.cloudflare.com",
        "time.apple.com",
    ]

    private static let ntpPort: UInt16 = 123
    private static let timeoutSeconds: Double = 3.0

    /// Seconds between 1900-01-01 and 1970-01-01
    private static let seconds1900To1970: Int64 = 2_208_988_800

    // Buffer matching legacy: 25ms base + 140ms on first sync = 165ms
    public static let bufferFirstSyncMicros: Int64 = 165_000
    public static let bufferMicros: Int64 = 25_000

    // Re-sync interval
    public static let resyncIntervalSeconds: Double = 60.0

    // MARK: - State

    public private(set) var offsetMicros: Int64 = 0
    public private(set) var isSynced: Bool = false
    public private(set) var syncedTimeMicros: Int64 = 0
    public private(set) var localReferenceMicros: Int64 = 0

    public var syncSource: SyncSource {
        isSynced ? .ntp : .deviceClock
    }

    private let logger = Logger(subsystem: "com.onemdev.gandalf", category: "NtpClient")

    public init() {}

    // MARK: - Public API

    public func sync() async -> SyncResult {
        logger.info("NTP sync starting — querying \(Self.ntpServers.count) servers")

        let localTimeBefore = Int64(Date().timeIntervalSince1970 * 1_000_000)
        logger.debug("NTP: localTimeBefore=\(localTimeBefore)µs")

        var offsets: [Int64] = []

        await withTaskGroup(of: Int64?.self) { group in
            for server in Self.ntpServers {
                group.addTask {
                    await self.queryServer(host: server)
                }
            }
            for await result in group {
                if let offset = result {
                    offsets.append(offset)
                }
            }
        }

        logger.info("NTP: \(offsets.count)/\(Self.ntpServers.count) servers responded")

        if offsets.count < 2 {
            logger.warning("NTP sync failed: only \(offsets.count) server(s) responded, falling back to device clock")

            // If we've never synced before, use device time as reference (offset = 0)
            // so the seek calculation still produces a valid position.
            if !isSynced {
                let refMicros = Int64(Date().timeIntervalSince1970 * 1_000_000)
                localReferenceMicros = refMicros
                syncedTimeMicros = refMicros  // offset = 0 → synced = local
                offsetMicros = 0
            }
            // Otherwise keep the previous successful NTP values — they remain
            // valid until the next successful re-sync.

            return SyncResult(
                offsetMicros: offsetMicros,
                source: syncSource,
                syncedTimeMicros: syncedTimeMicros,
                localReferenceMicros: localReferenceMicros
            )
        }

        offsets.sort()
        let median = offsets[offsets.count / 2]

        // Snapshot local time right after NTP queries complete
        let refMicros = Int64(Date().timeIntervalSince1970 * 1_000_000)
        let syncedMicros = refMicros + median

        offsetMicros = median
        isSynced = true
        localReferenceMicros = refMicros
        syncedTimeMicros = syncedMicros

        logger.info("NTP sync complete: offset=\(Double(median) / 1000.0)ms, syncedTime=\(syncedMicros)µs, localRef=\(refMicros)µs")
        return SyncResult(
            offsetMicros: median,
            source: .ntp,
            syncedTimeMicros: syncedMicros,
            localReferenceMicros: refMicros
        )
    }

    // MARK: - Private

    private let queryQueue = DispatchQueue(label: "com.onemdev.gandalf.ntp", qos: .utility)

    /// Query a single NTP server. Returns offset in microseconds, or nil on failure.
    private func queryServer(host: String) async -> Int64? {
        await withCheckedContinuation { continuation in
            let resumed = UnsafeSendableBox(value: false)

            func resumeOnce(returning value: Int64?) {
                guard !resumed.value else { return }
                resumed.value = true
                continuation.resume(returning: value)
            }

            let connection = NWConnection(
                host: NWEndpoint.Host(host),
                port: NWEndpoint.Port(rawValue: Self.ntpPort)!,
                using: .udp
            )

            let timer = DispatchSource.makeTimerSource(queue: queryQueue)
            timer.schedule(deadline: .now() + Self.timeoutSeconds)
            timer.setEventHandler { [logger] in
                logger.debug("NTP timeout for \(host)")
                connection.cancel()
            }
            timer.resume()

            connection.stateUpdateHandler = { [logger] state in
                switch state {
                case .ready:
                    var packet = Data(count: 48)
                    packet[0] = 0x23

                    let t1Ms = Int64(Date().timeIntervalSince1970 * 1000)
                    Self.writeTimestamp(into: &packet, at: 40, millis: t1Ms)

                    // Register receive handler BEFORE sending to avoid race condition.
                    connection.receive(minimumIncompleteLength: 48, maximumLength: 48) { data, _, _, error in
                        timer.cancel()

                        if let error = error {
                            logger.debug("NTP receive error from \(host): \(error.localizedDescription)")
                            resumeOnce(returning: nil)
                            connection.cancel()
                            return
                        }

                        guard let data = data, data.count >= 48 else {
                            logger.debug("NTP bad response from \(host): \(data?.count ?? 0) bytes")
                            resumeOnce(returning: nil)
                            connection.cancel()
                            return
                        }

                        let t4Ms = Int64(Date().timeIntervalSince1970 * 1000)
                        let t2Ms = Self.readTimestamp(from: data, at: 32)
                        let t3Ms = Self.readTimestamp(from: data, at: 40)

                        let offsetMs = Double((t2Ms - t1Ms) + (t3Ms - t4Ms)) / 2.0
                        let offsetMicros = Int64(offsetMs * 1000.0)

                        logger.info("NTP \(host): offset=\(offsetMs)ms, rtt=\(t4Ms - t1Ms)ms")
                        resumeOnce(returning: offsetMicros)
                        connection.cancel()
                    }

                    connection.send(content: packet, completion: .contentProcessed { error in
                        if let error = error {
                            logger.debug("NTP send to \(host) failed: \(error.localizedDescription)")
                            timer.cancel()
                            resumeOnce(returning: nil)
                        }
                    })

                case .failed(let error):
                    logger.debug("NTP connection to \(host) failed: \(error.localizedDescription)")
                    timer.cancel()
                    resumeOnce(returning: nil)

                case .cancelled:
                    timer.cancel()
                    resumeOnce(returning: nil)

                case .waiting(let error):
                    logger.debug("NTP connection to \(host) waiting: \(error.localizedDescription)")

                default:
                    break
                }
            }

            connection.start(queue: queryQueue)
        }
    }

    // MARK: - NTP Timestamp Helpers

    private static func writeTimestamp(into data: inout Data, at offset: Int, millis: Int64) {
        let seconds = millis / 1000 + seconds1900To1970
        let fraction = UInt64((millis % 1000 + 1000) % 1000) * 4_294_967_296 / 1000

        data[offset]     = UInt8(truncatingIfNeeded: seconds >> 24)
        data[offset + 1] = UInt8(truncatingIfNeeded: seconds >> 16)
        data[offset + 2] = UInt8(truncatingIfNeeded: seconds >> 8)
        data[offset + 3] = UInt8(truncatingIfNeeded: seconds)
        data[offset + 4] = UInt8(truncatingIfNeeded: fraction >> 24)
        data[offset + 5] = UInt8(truncatingIfNeeded: fraction >> 16)
        data[offset + 6] = UInt8(truncatingIfNeeded: fraction >> 8)
        data[offset + 7] = UInt8(truncatingIfNeeded: fraction)
    }

    private static func readTimestamp(from data: Data, at offset: Int) -> Int64 {
        let seconds = Int64(data[offset]) << 24
            | Int64(data[offset + 1]) << 16
            | Int64(data[offset + 2]) << 8
            | Int64(data[offset + 3])

        let fraction = UInt64(data[offset + 4]) << 24
            | UInt64(data[offset + 5]) << 16
            | UInt64(data[offset + 6]) << 8
            | UInt64(data[offset + 7])

        let unixSeconds = seconds - seconds1900To1970
        let millis = Int64(fraction * 1000 / 4_294_967_296)
        return unixSeconds * 1000 + millis
    }
}

/// Thread-safe box to guard against double-resume of CheckedContinuation.
/// Safe because all reads/writes happen on the same serial dispatch queue.
private final class UnsafeSendableBox<T> {
    var value: T
    init(value: T) { self.value = value }
}
extension UnsafeSendableBox: @unchecked Sendable {}
