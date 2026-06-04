import { NtpClient, SyncSource } from "./ntp";
import {
	logPlaybackStarted,
	logPlaybackResumed,
	logPlaybackPaused,
	logToggleMute,
	logChangeVolume,
} from "./analytics";

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
	/** Volume level 0–1 */
	volume: number;
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
	volume: 1,
	pauseOnSheetOpen: true,
});

// --- Video element reference ---
// Registered by VideoPlayer on mount so store actions can control playback.
let _videoElement: HTMLVideoElement | null = null;

export function registerVideoElement(el: HTMLVideoElement) {
	_videoElement = el;
}

/** Seek to NTP-synced position: (Date.now() + offset) % duration + buffer */
export function seekToSyncedPosition() {
	if (!_videoElement) return;
	const durationSec = _videoElement.duration;
	if (durationSec <= 0) return;
	_videoElement.currentTime = ntpClient.seekPositionSec(durationSec);
}

let _hasStartedPlayback = false;

/** Pause the video. `reason` is reported to analytics (e.g. "open_sheet", "manual"). */
export function pause(reason = "manual") {
	if (!_videoElement) return;
	_videoElement.pause();
	videoState.isPlaying = false;
	logPlaybackPaused(reason);
}

/** Seek to synced position and play. `reason` is reported to analytics. */
export function play(reason = "manual") {
	if (!_videoElement) return;
	seekToSyncedPosition();
	_videoElement.play();
	videoState.isPlaying = true;
	if (_hasStartedPlayback) {
		logPlaybackResumed(reason);
	} else {
		_hasStartedPlayback = true;
		logPlaybackStarted();
	}
}

// --- Action functions ---

export function toggleFullscreen() {
	if (!document.fullscreenElement) {
		document.documentElement.requestFullscreen();
	} else {
		document.exitFullscreen();
	}
}

export function toggleMute() {
	if (videoState.isMuted || videoState.volume === 0) {
		videoState.isMuted = false;
		videoState.volume = _prevVolume > 0 ? _prevVolume : 1;
	} else {
		_prevVolume = videoState.volume;
		videoState.isMuted = true;
		videoState.volume = 0;
	}
	logToggleMute(videoState.isMuted);
}

let _prevVolume = 1;
let _hasPlayedOnce = false;
let _volumeLogTimer: ReturnType<typeof setTimeout> | undefined;

/** Unmute on first user interaction (satisfies browser autoplay policy). */
export function firstPlayUnmute() {
	if (_hasPlayedOnce) return;
	videoState.isMuted = false;
	_hasPlayedOnce = true;
}

export function setVolume(v: number) {
	videoState.volume = v;
	if (v === 0) {
		videoState.isMuted = true;
	} else {
		videoState.isMuted = false;
		_prevVolume = v;
	}
	// Debounce: the slider fires many events while dragging.
	clearTimeout(_volumeLogTimer);
	_volumeLogTimer = setTimeout(() => logChangeVolume(videoState.volume), 400);
}
