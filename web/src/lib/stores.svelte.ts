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
	isMuted: boolean;
	/** Whether clicking the video pauses it before opening settings */
	pauseOnSheetOpen: boolean;
}

// Singleton NTP client (class instance, not reactive)
export const ntpClient = new NtpClient();

// --- Reactive state using $state rune (Svelte 5 best practice) ---
// Using module-level $state in a .svelte.ts file for shared state.
// Exported as const objects so consumers mutate properties, not reassign.

function loadPersisted<T>(key: string, initial: T): T {
	if (typeof window === "undefined") return initial;
	const stored = localStorage.getItem(key);
	if (stored) {
		try {
			return JSON.parse(stored) as T;
		} catch {
			return initial;
		}
	}
	return initial;
}

// Theme mode — persisted to localStorage
let _themeMode = $state<ThemeMode>(loadPersisted("gandalf_theme", "system"));

export function getThemeMode(): ThemeMode {
	return _themeMode;
}

export function setThemeMode(mode: ThemeMode): void {
	_themeMode = mode;
	if (typeof window !== "undefined") {
		localStorage.setItem("gandalf_theme", JSON.stringify(mode));
	}
}

// Video state — shared mutable object
export const videoState = $state<VideoState>({
	isPlaying: false,
	isSynced: false,
	syncSource: SyncSource.DEVICE_CLOCK,
	currentPosition: 0,
	duration: 117540, // 117.54 seconds in ms, matching native
	isSettingsOpen: true,
	isFullscreen: false,
	isMuted: true,
	pauseOnSheetOpen: true,
});

// --- Action functions ---

export function toggleFullscreen() {
	if (!document.fullscreenElement) {
		document.documentElement.requestFullscreen();
	} else {
		document.exitFullscreen();
	}
}

export function toggleMute() {
	videoState.isMuted = !videoState.isMuted;
}
