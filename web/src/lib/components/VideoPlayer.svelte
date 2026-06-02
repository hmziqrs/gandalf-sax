<script lang="ts">
	import { onMount } from "svelte";
	import { videoState, ntpClient, syncRefs } from "$lib/stores.svelte";
	import type { SyncResult } from "$lib/ntp";

	let videoElement: HTMLVideoElement;
	let animationFrame: number;
	let hasUnmuted = false;

	onMount(() => {
		if (!videoElement) return;

		// Start NTP sync (matching Swift: initialize → performSync → play → startResyncTimer)
		ntpClient.startAutoSync((result: SyncResult) => {
			videoState.isSynced = ntpClient.isSynced;
			videoState.syncSource = ntpClient.syncSource;
			// Store sync references (matching Swift: syncedTimeMicros / localReferenceMicros)
			syncRefs.syncedTimeMs = result.syncedTimeMs;
			syncRefs.localReferenceTimeMs = result.localReferenceTimeMs;
			seekToSyncedPosition();
		});

		// Start playback muted (required for autoplay)
		videoElement
			.play()
			.then(() => {
				videoState.isPlaying = true;
			})
			.catch(() => {
				videoState.isPlaying = false;
			});

		// Unmute on first user interaction
		const interactionEvents = ["click", "keydown", "touchstart"] as const;
		function handleFirstInteraction() {
			if (!hasUnmuted && videoElement) {
				videoElement.muted = false;
				hasUnmuted = true;
			}
			interactionEvents.forEach((evt) =>
				document.removeEventListener(evt, handleFirstInteraction)
			);
		}
		interactionEvents.forEach((evt) =>
			document.addEventListener(evt, handleFirstInteraction, { once: true })
		);

		// Track position
		const trackPosition = () => {
			if (videoElement) {
				videoState.currentPosition = videoElement.currentTime * 1000;
			}
			animationFrame = requestAnimationFrame(trackPosition);
		};
		animationFrame = requestAnimationFrame(trackPosition);

		return () => {
			ntpClient.stopAutoSync();
			if (animationFrame) cancelAnimationFrame(animationFrame);
		};
	});

	/** Full NTP seek — used after sync (matching Swift performSync) */
	function seekToSyncedPosition() {
		if (!videoElement) return;
		const durationMs = videoElement.duration * 1000;
		if (durationMs <= 0) return;
		const seekSec = ntpClient.seekPositionSec(durationMs / 1000);
		videoElement.currentTime = seekSec;
	}

	/**
	 * Seek using stored references — matching Swift VideoViewModel.syncVideo()
	 * which uses stored syncedTimeMicros + localReferenceMicros without re-syncing.
	 */
	function syncVideo() {
		if (!videoElement) return;
		const durationMs = videoElement.duration * 1000;
		if (durationMs <= 0) return;

		if (syncRefs.syncedTimeMs === 0) {
			// No stored reference yet — fall back to full sync
			seekToSyncedPosition();
		} else {
			const seekMs = ntpClient.seekPositionFromRefs(
				syncRefs.syncedTimeMs,
				syncRefs.localReferenceTimeMs,
				durationMs
			);
			videoElement.currentTime = seekMs / 1000;
		}
		videoElement.play();
		videoState.isPlaying = true;
	}

	/**
	 * Tap handler — matching Swift ContentView:
	 *   .onTapGesture { viewModel.pause(); showSettings = true }
	 */
	function handleVideoClick(e: MouseEvent) {
		e.stopPropagation();
		// Pause + open settings
		if (videoElement) {
			videoElement.pause();
		}
		videoState.isPlaying = false;
		videoState.isSettingsOpen = true;
	}

	/**
	 * Called when settings sheet closes — matching Swift:
	 *   .sheet(onDismiss: { viewModel.syncVideo() })
	 */
	export function onResumeFromSettings() {
		syncVideo();
	}

	function handleLoadedMetadata() {
		if (videoElement) {
			seekToSyncedPosition();
		}
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
		autoplay
		onloadedmetadata={handleLoadedMetadata}
		class="w-full h-full object-contain bg-black"
	></video>

	<div class="hint-text">Press F for fullscreen · Click for settings</div>
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

	.hint-text {
		position: absolute;
		bottom: 1.5rem;
		left: 50%;
		transform: translateX(-50%);
		color: rgba(255, 255, 255, 0.3);
		font-size: 0.75rem;
		pointer-events: none;
		animation: fadeInOut 4s ease-in-out forwards;
	}

	@keyframes fadeInOut {
		0% { opacity: 0; }
		20% { opacity: 1; }
		80% { opacity: 1; }
		100% { opacity: 0; }
	}
</style>
