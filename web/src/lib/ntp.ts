// NTP client for the web version
// Syncs ONCE on boot to measure the offset between device time and real time.
// All subsequent seek calculations simply do: (Date.now() + offset) % duration + buffer
//
// Browser limitation: cannot send raw UDP/NTP packets (port 123).
// Uses timeapi.io which returns nanosecond-precision timestamps.
// The offset is calculated using the RTT-midpoint technique with
// performance.now() for sub-millisecond RTT measurement.

// Buffer matching Swift: 165ms (25 + 140)
const BUFFER = 165;

export enum SyncSource {
	NTP = "NTP",
	DEVICE_CLOCK = "DEVICE_CLOCK",
}

export interface SyncResult {
	offsetMs: number;
	source: SyncSource;
}

/**
 * Parse timeapi.io's nanosecond-precision dateTime string into
 * fractional milliseconds (preserving sub-ms precision).
 * e.g. "2026-06-03T02:32:00.8729464" → 1780435920872.9464
 */
function parseNanoTime(dateTime: string): number {
	const [datePart, timePart] = dateTime.split("T");
	const [year, month, day] = datePart.split("-").map(Number);
	const secPart = timePart.split(".")[0];
	const fracPart = timePart.split(".")[1] || "0";
	const [hours, minutes, seconds] = secPart.split(":").map(Number);

	// Build ms since epoch for the whole-second portion
	const epochMs = Date.UTC(year, month - 1, day, hours, minutes, seconds);

	// Parse fractional seconds (7 digits = 100ns precision) → ms
	const fracDigits = fracPart.length;
	const fracMs = Number(fracPart) / 10 ** (fracDigits - 3);

	return epochMs + fracMs;
}

async function getTimeOffset(): Promise<number | null> {
	try {
		const t0 = performance.now();
		const res = await fetch(
			`https://timeapi.io/api/time/current/zone?timeZone=UTC&t=${Date.now()}`
		);
		const t1 = performance.now();

		if (!res.ok) return null;

		const data = await res.json();
		const serverTime = parseNanoTime(data.dateTime);
		const rtt = t1 - t0;
		const clientTime = t0 + rtt / 2;
		return serverTime - clientTime;
	} catch {
		return null;
	}
}

export class NtpClient {
	private offsetMs = 0;
	private synced = false;

	get isSynced(): boolean {
		return this.synced;
	}

	get syncSource(): SyncSource {
		return this.synced ? SyncSource.NTP : SyncSource.DEVICE_CLOCK;
	}

	/** Sync once per session — single request to measure clock offset */
	async sync(): Promise<SyncResult> {
		const offset = await getTimeOffset();

		if (offset !== null) {
			this.offsetMs = offset;
			this.synced = true;
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
		let raw = ((nowMs + this.offsetMs) % durationMs) + BUFFER;
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
