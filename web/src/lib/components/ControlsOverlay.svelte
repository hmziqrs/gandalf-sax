<script lang="ts">
	import { onMount } from "svelte";
	import { videoState, toggleFullscreen, toggleMute } from "$lib/stores.svelte";
	import { Button } from "$lib/components/ui/button/index.js";
	import {
		Root as TooltipRoot,
		Trigger as TooltipTrigger,
		Provider as TooltipProvider,
	} from "$lib/components/ui/tooltip/index.js";
	import TooltipContent from "$lib/components/ui/tooltip/TooltipContent.svelte";
	import { Maximize, Minimize, Volume2, VolumeX } from "@lucide/svelte";

	let visible = $state(true);
	let hideTimeout: ReturnType<typeof setTimeout>;

	function scheduleHide() {
		clearTimeout(hideTimeout);
		visible = true;
		hideTimeout = setTimeout(() => {
			visible = false;
		}, 4000);
	}

	function handleWindowMouseMove() {
		scheduleHide();
	}

	function handleMouseEnter() {
		clearTimeout(hideTimeout);
		visible = true;
	}

	function handleMouseLeave() {
		scheduleHide();
	}

	function handleFullscreenClick(e: MouseEvent) {
		e.stopPropagation();
		toggleFullscreen();
	}

	function handleMuteClick(e: MouseEvent) {
		e.stopPropagation();
		toggleMute();
	}

	onMount(() => {
		scheduleHide();
		return () => clearTimeout(hideTimeout);
	});
</script>

<svelte:window onmousemove={handleWindowMouseMove} />

{#if visible}
	<div
		class="controls-overlay"
		onmouseenter={handleMouseEnter}
		onmouseleave={handleMouseLeave}
	>
		<TooltipProvider delayDuration={300}>
			<div class="controls-row">
				<!-- Volume toggle -->
				<TooltipRoot>
					<TooltipTrigger>
						{#snippet child({ props })}
							<Button
								{...props}
								variant="ghost"
								size="icon"
								class="control-btn"
								onclick={handleMuteClick}
								aria-label={videoState.isMuted ? "Unmute" : "Mute"}
							>
								{#if videoState.isMuted}
									<VolumeX size={16} />
								{:else}
									<Volume2 size={16} />
								{/if}
							</Button>
						{/snippet}
					</TooltipTrigger>
					<TooltipContent side="top">
						{videoState.isMuted ? "Unmute" : "Mute"}
					</TooltipContent>
				</TooltipRoot>

				<!-- Fullscreen toggle -->
				<TooltipRoot>
					<TooltipTrigger>
						{#snippet child({ props })}
							<Button
								{...props}
								variant="ghost"
								size="icon"
								class="control-btn"
								onclick={handleFullscreenClick}
								aria-label={videoState.isFullscreen ? "Exit fullscreen" : "Fullscreen"}
							>
								{#if videoState.isFullscreen}
									<Minimize size={16} />
								{:else}
									<Maximize size={16} />
								{/if}
							</Button>
						{/snippet}
					</TooltipTrigger>
					<TooltipContent side="top">
						{videoState.isFullscreen ? "Exit Fullscreen" : "Fullscreen"}
					</TooltipContent>
				</TooltipRoot>
			</div>
		</TooltipProvider>
	</div>
{/if}

<style>
	.controls-overlay {
		position: absolute;
		bottom: 1rem;
		right: 1rem;
		z-index: 10;
		animation: controlsFadeIn 0.3s ease-in-out;
	}

	.controls-row {
		display: flex;
		align-items: center;
		gap: 0.25rem;
		background: rgba(0, 0, 0, 0.4);
		backdrop-filter: blur(8px);
		border-radius: 0.5rem;
		padding: 0.25rem;
	}

	.controls-row :global(.control-btn) {
		color: rgba(255, 255, 255, 0.8) !important;
		background: transparent !important;
		border: none !important;
		height: 2rem !important;
		width: 2rem !important;
		box-shadow: none !important;
	}

	.controls-row :global(.control-btn:hover) {
		color: white !important;
		background: rgba(255, 255, 255, 0.1) !important;
	}

	@keyframes controlsFadeIn {
		from { opacity: 0; }
		to { opacity: 1; }
	}
</style>
