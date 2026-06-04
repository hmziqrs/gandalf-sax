<script lang="ts">
	import { onMount } from "svelte";
	import {
		videoState,
		ntpClient,
		registerVideoElement,
		seekToSyncedPosition,
		play,
		pause,
		firstPlayUnmute,
	} from "$lib/stores.svelte";
	import {
		logViewHomeScreen,
		logVideoLoaded,
		logPlayerError,
		logOpenSheet,
		logResync,
		logSyncCompleted,
		logSyncFailed,
	} from "$lib/analytics";
	import { SyncSource } from "$lib/ntp";
	import ControlsOverlay from "./ControlsOverlay.svelte";

	let videoElement: HTMLVideoElement;
	let animationFrame: number;

	onMount(() => {
		if (!videoElement) return;

		logViewHomeScreen();

		// Register the video element so store actions can control it
		registerVideoElement(videoElement);

		// Sync NTP once on boot to measure offset, then reuse it forever
		ntpClient.sync().then((result) => {
			videoState.isSynced = ntpClient.isSynced;
			videoState.syncSource = ntpClient.syncSource;
			seekToSyncedPosition();

			logSyncCompleted(result.source, result.offsetMs);
			if (result.source === SyncSource.DEVICE_CLOCK) {
				logSyncFailed();
			}
		});

		// Track position
		const trackPosition = () => {
			if (videoElement) {
				videoState.currentPosition = videoElement.currentTime * 1000;
			}
			animationFrame = requestAnimationFrame(trackPosition);
		};
		animationFrame = requestAnimationFrame(trackPosition);

		return () => {
			if (animationFrame) cancelAnimationFrame(animationFrame);
		};
	});

	// Sync muted state to the video element reactively
	$effect(() => {
		if (videoElement) {
			videoElement.muted = videoState.isMuted;
		}
	});

	// Sync volume level to the video element reactively
	$effect(() => {
		if (videoElement) {
			videoElement.volume = videoState.volume;
		}
	});

	/**
	 * Tap handler — opens settings sheet.
	 * Respects the pauseOnSheetOpen setting.
	 */
	function handleVideoClick(e: MouseEvent) {
		e.stopPropagation();
		if (videoState.pauseOnSheetOpen) {
			pause("open_sheet");
		}
		videoState.isSettingsOpen = true;
		logOpenSheet();
	}

	/**
	 * Called when settings sheet closes — matching Swift:
	 *   .sheet(onDismiss: { viewModel.syncVideo() })
	 *
	 * On first call (boot sheet closing), unmutes and starts playback —
	 * the user's close click satisfies the browser autoplay policy.
	 */
	export function onResumeFromSettings() {
		play("sheet_close");
		firstPlayUnmute();
		logResync("sheet_close");
	}

	function handleLoadedMetadata() {
		seekToSyncedPosition();
		logVideoLoaded(videoElement.duration * 1000);
	}

	function handleVideoError() {
		const err = videoElement?.error;
		logPlayerError(err ? `code ${err.code}: ${err.message}` : "unknown");
	}
</script>

<!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions -->
<div
	class="video-container"
	onclick={handleVideoClick}
	role="button"
	tabindex="0"
	aria-label="Open settings"
>
	<video
		bind:this={videoElement}
		src="/video.mp4"
		loop
		muted
		playsinline
		onloadedmetadata={handleLoadedMetadata}
		onerror={handleVideoError}
		class="w-full h-full object-contain bg-black"
	></video>

	<ControlsOverlay />
</div>

<style>
	.video-container {
		position: fixed;
		top: 0;
		left: 0;
		width: 100vw;
		height: 100vh;
		background: black;
		cursor: pointer;
		z-index: 0;
	}
</style>
