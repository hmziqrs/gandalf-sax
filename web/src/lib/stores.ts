import { writable } from "svelte/store";
import { NtpClient, SyncSource } from "./ntp";

export type ThemeMode = "light" | "dark" | "system";

export interface VideoState {
	isPlaying: boolean;
	isSynced: boolean;
	syncSource: SyncSource;
	currentPosition: number;
	/** Video duration in milliseconds */
	duration: number;
	isSettingsOpen: boolean;
	isFullscreen: boolean;
}

// Stored sync references — mirrors Swift VideoViewModel state
export interface SyncRefs {
	syncedTimeMs: number;
	localReferenceTimeMs: number;
}

// Persisted store helper
function createPersistedStore<T>(key: string, initial: T) {
	let value = initial;
	if (typeof window !== "undefined") {
		const stored = localStorage.getItem(key);
		if (stored) {
			try {
				value = JSON.parse(stored);
			} catch {
				value = initial;
			}
		}
	}
	const store = writable<T>(value);

	store.subscribe((val) => {
		if (typeof window !== "undefined") {
			localStorage.setItem(key, JSON.stringify(val));
		}
	});

	return store;
}

export const themeMode = createPersistedStore<ThemeMode>("gandalf_theme", "system");

// Singleton NTP client
export const ntpClient = new NtpClient();

// Stored sync references — updated on each NTP sync, used by syncVideo()
export const syncRefs = writable<SyncRefs>({
	syncedTimeMs: 0,
	localReferenceTimeMs: 0,
});

export const videoState = writable<VideoState>({
	isPlaying: false,
	isSynced: false,
	syncSource: SyncSource.DEVICE_CLOCK,
	currentPosition: 0,
	duration: 117540, // 117.54 seconds in ms, matching native
	isSettingsOpen: false,
	isFullscreen: false,
});
