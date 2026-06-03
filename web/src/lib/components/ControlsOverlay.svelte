<script lang="ts">
	import { onMount } from "svelte";
	import {
		videoState,
		toggleFullscreen,
		toggleMute,
		setVolume,
	} from "$lib/stores.svelte";
	import { Button } from "$lib/components/ui/button/index.js";
	import {
		Root as TooltipRoot,
		Trigger as TooltipTrigger,
		Provider as TooltipProvider,
	} from "$lib/components/ui/tooltip/index.js";
	import TooltipContent from "$lib/components/ui/tooltip/TooltipContent.svelte";
	import {
		Maximize,
		Minimize,
		Volume2,
		VolumeX,
		Volume1,
	} from "@lucide/svelte";

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

	function handleVolumeInput(e: Event) {
		e.stopPropagation();
		const target = e.target as HTMLInputElement;
		setVolume(parseFloat(target.value));
	}

	function handleVolumeClick(e: MouseEvent) {
		e.stopPropagation();
	}

	let VolumeIcon = $derived(
		videoState.isMuted || videoState.volume === 0
			? VolumeX
			: videoState.volume < 0.5
				? Volume1
				: Volume2
	);

	onMount(() => {
		scheduleHide();
		return () => clearTimeout(hideTimeout);
	});
</script>

<svelte:window onmousemove={handleWindowMouseMove} />

{#if visible}
	<div
		role="region"
		aria-label="Video controls"
		class="controls-overlay"
		onmouseenter={handleMouseEnter}
		onmouseleave={handleMouseLeave}
	>
		<TooltipProvider delayDuration={300}>
			<div class="controls-group">
				<!-- Volume button + slider -->
				<div class="volume-control">
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
									<VolumeIcon size={16} />
								</Button>
							{/snippet}
						</TooltipTrigger>
						<TooltipContent side="top">
							{videoState.isMuted ? "Unmute" : "Mute"}
						</TooltipContent>
					</TooltipRoot>
					<!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions -->
				<div class="volume-slider-wrapper" role="slider" onclick={handleVolumeClick}>
						<input
							type="range"
							min="0"
							max="1"
							step="0.01"
							value={videoState.volume}
							oninput={handleVolumeInput}
							onclick={handleVolumeClick}
							class="volume-slider"
							aria-label="Volume"
						/>
					</div>
				</div>

				<!-- Divider -->
				<div class="controls-divider"></div>

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

	.controls-group {
		display: flex;
		align-items: center;
		gap: 0.375rem;
		background: rgba(0, 0, 0, 0.4);
		backdrop-filter: blur(8px);
		border-radius: 0.5rem;
		padding: 0.375rem 0.5rem;
	}

	.controls-divider {
		width: 1px;
		height: 1.25rem;
		background: rgba(255, 255, 255, 0.2);
		flex-shrink: 0;
	}

	.volume-control {
		display: flex;
		align-items: center;
		gap: 0.25rem;
	}

	.volume-slider-wrapper {
		width: 80px;
		display: flex;
		align-items: center;
	}

	.volume-slider {
		-webkit-appearance: none;
		appearance: none;
		width: 100%;
		height: 4px;
		background: rgba(255, 255, 255, 0.25);
		border-radius: 2px;
		outline: none;
		cursor: pointer;
	}

	.volume-slider::-webkit-slider-thumb {
		-webkit-appearance: none;
		appearance: none;
		width: 14px;
		height: 14px;
		border-radius: 50%;
		background: white;
		cursor: pointer;
		box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
		transition: transform 0.15s ease;
	}

	.volume-slider::-webkit-slider-thumb:hover {
		transform: scale(1.2);
	}

	.volume-slider::-moz-range-thumb {
		width: 14px;
		height: 14px;
		border-radius: 50%;
		background: white;
		cursor: pointer;
		border: none;
		box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
	}

	.volume-slider::-moz-range-track {
		height: 4px;
		background: rgba(255, 255, 255, 0.25);
		border-radius: 2px;
	}

	.controls-group :global(.control-btn) {
		color: rgba(255, 255, 255, 0.8) !important;
		background: transparent !important;
		border: none !important;
		height: 2rem !important;
		width: 2rem !important;
		box-shadow: none !important;
	}

	.controls-group :global(.control-btn:hover) {
		color: white !important;
		background: rgba(255, 255, 255, 0.1) !important;
	}

	@keyframes controlsFadeIn {
		from { opacity: 0; }
		to { opacity: 1; }
	}
</style>
