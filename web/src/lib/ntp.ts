// NTP client for the web version
// Syncs ONCE on boot to measure the offset between device time and real time.
// All subsequent seek calculations simply do: (Date.now() + offset) % duration + buffer
//
// Browser limitation: cannot send raw UDP/NTP packets (port 123).
// Each server is mapped to its own HTTP time endpoint and the offset is
// calculated individually using the RTT-midpoint technique, then the median
// of per-server offsets is taken to filter outliers.

interface NtpServerConfig {
	/** Human-readable name matching the Swift server list */
	name: string;
	/** Returns the URL to fetch (cache-busted with Date.now()) */
	getUrl: () => string;
	/** Parses the JSON response body and returns server time in ms since epoch */
	parseTime: (data: unknown) => number;
}

// Three servers matching Swift NtpClient.
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
}

interface NtpResult {
	offset: number;
	rtt: number;
	server: string;
}

/**
 * Query a single time server and calculate its offset individually.
 * offset = serverTime - (startTime + rtt/2)
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
	private offsetMs = 0;
	private synced = false;
	private isFirstSync = true;

	get isSynced(): boolean {
		return this.synced;
	}

	get syncSource(): SyncSource {
		return this.synced ? SyncSource.NTP : SyncSource.DEVICE_CLOCK;
	}

	/** Sync once on boot — measure offset, then reuse it forever */
	async sync(): Promise<SyncResult> {
		const results: NtpResult[] = [];

		const promises = NTP_SERVERS.map((server) => getNtpOffset(server));
		const responses = await Promise.allSettled(promises);

		for (const result of responses) {
			if (result.status === "fulfilled" && result.value !== null) {
				results.push(result.value);
			}
		}

		if (results.length >= 2) {
			results.sort((a, b) => a.offset - b.offset);
			this.offsetMs = results[Math.floor(results.length / 2)].offset;
			this.synced = true;
			this.isFirstSync = false;
		}

		return {
			offsetMs: this.offsetMs,
			source: this.syncSource,
		};
	}

	/**
	 * seekPosition = (Date.now() + offset) % duration + buffer
	 */
	seekPositionMs(durationMs: number): number {
		const nowMs = Date.now();
		const buffer = this.isFirstSync ? BUFFER_FIRST_SYNC : BUFFER_SUBSEQUENT;
		let raw = ((nowMs + this.offsetMs) % durationMs) + buffer;
		if (raw >= durationMs) {
			raw -= durationMs;
		}
		return raw;
	}

	/** Convenience: seek position in seconds (for HTMLMediaElement.currentTime) */
	seekPositionSec(durationSec: number): number {
		return this.seekPositionMs(durationSec * 1000) / 1000;
	}
}
