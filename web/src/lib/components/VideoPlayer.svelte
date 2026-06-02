<script lang="ts">
	import { onMount } from "svelte";
	import {
		videoState,
		ntpClient,
		registerVideoElement,
		seekToSyncedPosition,
		play,
		pause,
	} from "$lib/stores.svelte";
	import ControlsOverlay from "./ControlsOverlay.svelte";

	let videoElement: HTMLVideoElement;
	let animationFrame: number;
	let hasPlayedOnce = false;

	onMount(() => {
		if (!videoElement) return;

		// Register the video element so store actions can control it
		registerVideoElement(videoElement);

		// Sync NTP once on boot to measure offset, then reuse it forever
		ntpClient.sync().then(() => {
			videoState.isSynced = ntpClient.isSynced;
			videoState.syncSource = ntpClient.syncSource;
			seekToSyncedPosition();
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

	/**
	 * Tap handler — opens settings sheet.
	 * Respects the pauseOnSheetOpen setting.
	 */
	function handleVideoClick(e: MouseEvent) {
		e.stopPropagation();
		if (videoState.pauseOnSheetOpen) {
			pause();
		}
		videoState.isSettingsOpen = true;
	}

	/**
	 * Called when settings sheet closes — matching Swift:
	 *   .sheet(onDismiss: { viewModel.syncVideo() })
	 *
	 * On first call (boot sheet closing), unmutes and starts playback —
	 * the user's close click satisfies the browser autoplay policy.
	 */
	export function onResumeFromSettings() {
		play();
		if (!hasPlayedOnce) {
			videoState.isMuted = false;
			hasPlayedOnce = true;
		}
	}

	function handleLoadedMetadata() {
		seekToSyncedPosition();
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
