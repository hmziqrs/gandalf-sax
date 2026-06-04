// Firebase Analytics wrapper for the web app.
//
// Mirrors the legacy Flutter `Analytics` abstraction (legacy/lib/services/analytics.dart)
// and the native apps' event names, then expands the set across playback,
// NTP sync, UI navigation, and external-link categories.
//
// The site is a fully static, prerendered build, so everything here is
// client-only: initialization is guarded by `browser` and `isSupported()`,
// and is a no-op on the server or in unsupported environments. Events fired
// before init completes are buffered and flushed once analytics is ready.

import { browser } from "$app/environment";
import { initializeApp } from "firebase/app";
import {
	getAnalytics,
	isSupported,
	logEvent as fbLogEvent,
	type Analytics,
} from "firebase/analytics";
import { firebaseConfig } from "./firebase.config";

type Params = Record<string, string | number | boolean>;

let analytics: Analytics | null = null;
let initStarted = false;
const queue: Array<{ name: string; params?: Params }> = [];

/** Initialize Firebase Analytics. Idempotent; safe to call from layout onMount. */
export async function initAnalytics(): Promise<void> {
	if (!browser || initStarted) return;
	initStarted = true;
	try {
		if (!(await isSupported())) return;
		const app = initializeApp(firebaseConfig);
		analytics = getAnalytics(app);
		// Flush anything logged before init resolved.
		for (const { name, params } of queue) {
			fbLogEvent(analytics, name, params);
		}
	} catch (e) {
		console.warn("[analytics] init failed", e);
	} finally {
		queue.length = 0;
	}
}

/** Internal: log an event, or buffer it until init resolves. */
function track(name: string, params?: Params): void {
	if (!browser) return;
	if (!analytics) {
		// Buffer until ready (bounded — drop oldest if it grows unexpectedly).
		if (queue.length < 100) queue.push({ name, params });
		return;
	}
	try {
		fbLogEvent(analytics, name, params);
	} catch (e) {
		console.warn(`[analytics] event "${name}" failed`, e);
	}
}

// --- Core events (names preserved from legacy / native apps) ---

export const logViewHomeScreen = () => track("view_home_screen");
export const logPageView = (path: string) => track("page_view", { path });
export const logOpenSheet = () => track("open_sheet");
export const logCloseSheet = () => track("close_sheet");
export const logShareContent = () => track("share_content");
export const logChangeTheme = (themeMode: string) =>
	track("change_theme", { theme_mode: themeMode });
export const logTogglePauseOnOpen = (enabled: boolean) =>
	track("toggle_pause_on_open", { enabled });
export const logClickSocialLink = (platform: string, url: string) =>
	track("click_social_link", { platform, url });

// --- Playback lifecycle ---

export const logVideoLoaded = (durationMs: number) =>
	track("video_loaded", { duration_ms: Math.round(durationMs) });
export const logPlaybackStarted = () => track("playback_started");
export const logPlaybackPaused = (reason: string) =>
	track("playback_paused", { reason });
export const logPlaybackResumed = (reason: string) =>
	track("playback_resumed", { reason });
export const logPlayerError = (message: string) =>
	track("player_error", { message });

// --- NTP sync ---

export const logSyncCompleted = (source: string, offsetMs: number) =>
	track("sync_completed", { source, offset_ms: Math.round(offsetMs) });
export const logSyncFailed = () => track("sync_failed");
export const logResync = (trigger: string) => track("resync", { trigger });

// --- UI navigation ---

export const logToggleFullscreen = (enabled: boolean) =>
	track("toggle_fullscreen", { enabled });
export const logToggleMute = (muted: boolean) =>
	track("toggle_mute", { muted });
export const logChangeVolume = (volume: number) =>
	track("change_volume", { volume: Math.round(volume * 100) / 100 });

// --- External links ---

export const logClickOriginalVideo = (location: string) =>
	track("click_original_video", { location });
export const logClickExternalLink = (url: string, label: string) =>
	track("click_external_link", { url, label });
