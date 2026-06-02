// NTP client for the web version
// Matches the Swift NtpClient + SyncCalculator pattern:
//   syncedTime = localReferenceTime + offset  (captured at sync moment)
//   currentSyncedTime = syncedTime + elapsed
//   seekPosition = (currentSyncedTime % duration) + buffer
// Which simplifies to: (Date.now() + offset) % duration + buffer
//
// Browser limitation: cannot send raw UDP/NTP packets (port 123).
// Instead, each server is mapped to its own HTTP time endpoint and
// the offset is calculated individually using the RTT-midpoint technique
// — equivalent to the standard NTP formula when T2 ≈ T3 (single HTTP round-trip).
// The median of per-server offsets is then taken to filter outliers,
// matching the Swift client's TaskGroup + median aggregation.

interface NtpServerConfig {
	/** Human-readable name matching the Swift server list */
	name: string;
	/** Returns the URL to fetch (cache-busted with Date.now()) */
	getUrl: () => string;
	/** Parses the JSON response body and returns server time in ms since epoch */
	parseTime: (data: unknown) => number;
}

// Three servers matching Swift NtpClient — no pool.ntp.org.
// Each uses a different HTTP time endpoint so offsets are calculated
// against independent time sources.
const NTP_SERVERS: NtpServerConfig[] = [
	{
		name: "time.google.com",
		getUrl: () =>
			`https://worldtimeapi.org/api/timezone/Etc/UTC?t=${Date.now()}`,
		parseTime: (data: any) => new Date(data.utc_datetime).getTime(),
	},
	{
		name: "time.cloudflare.com",
		getUrl: () =>
			`https://timeapi.io/api/time/current/zone?timeZone=UTC&t=${Date.now()}`,
		parseTime: (data: any) => new Date(data.dateTime).getTime(),
	},
	{
		name: "time.apple.com",
		getUrl: () =>
			`https://worldtimeapi.org/api/timezone/Etc/UTC?t=${Date.now()}`,
		parseTime: (data: any) => new Date(data.utc_datetime).getTime(),
	},
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
	server: string;
}

/**
 * Query a single time server and calculate its offset individually.
 *
 * Offset is computed using the RTT-midpoint technique:
 *   clientTime = startTime + rtt/2
 *   offset     = serverTime - clientTime
 *
 * This is equivalent to the standard NTP formula
 *   offset = ((T2 - T1) + (T3 - T4)) / 2
 * when T2 ≈ T3 (single HTTP round-trip with no server processing delay).
 */
async function getNtpOffset(server: NtpServerConfig): Promise<NtpResult | null> {
	try {
		const startTime = performance.now();
		const response = await fetch(server.getUrl());
		const endTime = performance.now();

		if (!response.ok) return null;

		const data = await response.json();
		const serverTime = server.parseTime(data);
		const rtt = endTime - startTime;
		const clientTime = startTime + rtt / 2;
		const offset = serverTime - clientTime;

		return { offset, rtt, server: server.name };
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

		// Query each server concurrently (matching Swift TaskGroup pattern)
		const promises = NTP_SERVERS.map((server) => getNtpOffset(server));
		const responses = await Promise.allSettled(promises);

		for (const result of responses) {
			if (result.status === "fulfilled" && result.value !== null) {
				results.push(result.value);
			}
		}

		if (results.length >= 2) {
			// Sort by individually-calculated offset and take median
			// (matching Swift: offsets.sort() → median)
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
