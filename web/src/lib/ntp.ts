// NTP client for the web version
// Faithfully matches the Swift NtpClient + SyncCalculator pattern:
//   syncedTime = localReferenceTime + offset  (captured at sync moment)
//   currentSyncedTime = syncedTime + elapsed
//   seekPosition = (currentSyncedTime % duration) + buffer
// Which simplifies to: (Date.now() + offset) % duration + buffer

const NTP_SERVERS = [
	"time.google.com",
	"time.cloudflare.com",
	"time.apple.com",
	"pool.ntp.org",
];

const RESYNC_INTERVAL = 60_000; // 60 seconds, matching native

// Buffer constants matching Swift: 165ms first sync (25 + 140), 25ms subsequent
const BUFFER_FIRST_SYNC = 165;
const BUFFER_SUBSEQUENT = 25;

export enum SyncSource {
	NTP = "NTP",
	DEVICE_CLOCK = "DEVICE_CLOCK",
}

export interface SyncResult {
	offsetMs: number;
	source: SyncSource;
	/** NTP-corrected time captured at sync moment = localReferenceTime + offset */
	syncedTimeMs: number;
	/** Local device time snapshot at sync moment */
	localReferenceTimeMs: number;
}

interface NtpResult {
	offset: number;
	rtt: number;
}

// Use public time APIs since browsers can't do raw UDP/NTP.
// Queries worldtimeapi.org and computes offset from round-trip time.
async function getNtpOffset(_server: string): Promise<NtpResult | null> {
	try {
		const startTime = performance.now();
		const response = await fetch(
			`https://worldtimeapi.org/api/timezone/Etc/UTC?t=${Date.now()}`
		);
		const endTime = performance.now();

		if (!response.ok) return null;

		const data = await response.json();
		const serverTime = new Date(data.utc_datetime).getTime();
		const rtt = endTime - startTime;
		const clientTime = startTime + rtt / 2;
		const offset = serverTime - clientTime;

		return { offset, rtt };
	} catch {
		return null;
	}
}

export class NtpClient {
	// Stored sync state — matches Swift NtpClient actor state
	private offsetMs = 0;
	private synced = false;
	private localReferenceTimeMs = 0;
	private syncedTimeMs = 0;
	private isFirstSync = true;
	private syncInterval: ReturnType<typeof setInterval> | null = null;

	get isSynced(): boolean {
		return this.synced;
	}

	get syncSource(): SyncSource {
		return this.synced ? SyncSource.NTP : SyncSource.DEVICE_CLOCK;
	}

	/** Returns the last sync result for external storage (e.g. VideoViewModel) */
	get lastSyncResult(): SyncResult {
		return {
			offsetMs: this.offsetMs,
			source: this.syncSource,
			syncedTimeMs: this.syncedTimeMs,
			localReferenceTimeMs: this.localReferenceTimeMs,
		};
	}

	async sync(): Promise<SyncResult> {
		const results: NtpResult[] = [];

		// Query multiple servers concurrently (matching Swift TaskGroup pattern)
		const promises = NTP_SERVERS.map((server) => getNtpOffset(server));
		const responses = await Promise.allSettled(promises);

		for (const result of responses) {
			if (result.status === "fulfilled" && result.value !== null) {
				results.push(result.value);
			}
		}

		if (results.length >= 2) {
			// Sort by offset and take median (matching native)
			results.sort((a, b) => a.offset - b.offset);
			const medianOffset = results[Math.floor(results.length / 2)].offset;

			// Snapshot local time right after queries complete (matching Swift)
			const refMs = Date.now();
			const syncedMs = refMs + medianOffset;

			this.offsetMs = medianOffset;
			this.localReferenceTimeMs = refMs;
			this.syncedTimeMs = syncedMs;
			this.synced = true;
			this.isFirstSync = false;
		}

		return {
			offsetMs: this.offsetMs,
			source: this.syncSource,
			syncedTimeMs: this.syncedTimeMs,
			localReferenceTimeMs: this.localReferenceTimeMs,
		};
	}

	/**
	 * Calculate seek position using SyncCalculator logic:
	 *   elapsed = now - localReferenceTime
	 *   currentSyncedTime = syncedTime + elapsed  (= now + offset)
	 *   position = (currentSyncedTime % duration) + buffer
	 *   if position >= duration → position -= duration
	 */
	seekPositionMs(durationMs: number): number {
		const nowMs = Date.now();
		const elapsedMs = nowMs - this.localReferenceTimeMs;
		const currentSyncedMs = this.syncedTimeMs + elapsedMs;
		const buffer = this.isFirstSync ? BUFFER_FIRST_SYNC : BUFFER_SUBSEQUENT;
		let raw = (currentSyncedMs % durationMs) + buffer;
		if (raw >= durationMs) {
			raw -= durationMs;
		}
		return raw;
	}

	/** Convenience: seek position in seconds (for HTMLMediaElement.currentTime) */
	seekPositionSec(durationSec: number): number {
		return this.seekPositionMs(durationSec * 1000) / 1000;
	}

	/**
	 * Calculate seek position using stored external references
	 * (matches Swift VideoViewModel.syncVideo which uses stored state)
	 */
	seekPositionFromRefs(
		syncedTimeMs: number,
		localReferenceTimeMs: number,
		durationMs: number
	): number {
		const nowMs = Date.now();
		const elapsedMs = nowMs - localReferenceTimeMs;
		const currentSyncedMs = syncedTimeMs + elapsedMs;
		let raw = (currentSyncedMs % durationMs) + BUFFER_SUBSEQUENT;
		if (raw >= durationMs) {
			raw -= durationMs;
		}
		return raw;
	}

	startAutoSync(onSync?: (result: SyncResult) => void): void {
		this.sync().then((result) => onSync?.(result));

		this.syncInterval = setInterval(() => {
			this.sync().then((result) => onSync?.(result));
		}, RESYNC_INTERVAL);
	}

	stopAutoSync(): void {
		if (this.syncInterval) {
			clearInterval(this.syncInterval);
			this.syncInterval = null;
		}
	}
}
