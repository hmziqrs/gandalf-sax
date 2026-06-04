<script lang="ts">
	import VideoPlayer from "$lib/components/VideoPlayer.svelte";
	import SettingsSheet from "$lib/components/SettingsSheet.svelte";
	import { videoState, toggleFullscreen } from "$lib/stores.svelte";
	import { onMount } from "svelte";
	import Seo from "$lib/components/Seo.svelte";
	import { pages } from "$lib/seo";
	import { logToggleFullscreen } from "$lib/analytics";

	let videoPlayer: VideoPlayer;

	onMount(() => {
		function handleKeydown(e: KeyboardEvent) {
			if (e.key === "f" || e.key === "F") {
				toggleFullscreen();
			} else if (e.key === "Escape") {
				if (videoState.isFullscreen) {
					document.exitFullscreen();
					videoState.isFullscreen = false;
				}
			}
		}

		function handleFullscreenChange() {
			videoState.isFullscreen = !!document.fullscreenElement;
			logToggleFullscreen(videoState.isFullscreen);
		}

		document.addEventListener("keydown", handleKeydown);
		document.addEventListener("fullscreenchange", handleFullscreenChange);

		return () => {
			document.removeEventListener("keydown", handleKeydown);
			document.removeEventListener("fullscreenchange", handleFullscreenChange);
		};
	});

	/** Called when settings sheet closes — matching Swift sheet(onDismiss: syncVideo) */
	function handleSettingsClose() {
		videoPlayer?.onResumeFromSettings();
	}
</script>

<Seo seo={pages['/']} />
<svelte:head>
	<meta name="theme-color" content="#1E1E1E" />
</svelte:head>

<VideoPlayer bind:this={videoPlayer} />
<SettingsSheet onClose={handleSettingsClose} />
