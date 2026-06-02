<script lang="ts">
	import { Root as SheetRoot, Close as SheetClose } from "$lib/components/ui/sheet/index.js";
	import SheetContent from "$lib/components/ui/sheet/SheetContent.svelte";
	import SheetHeader from "$lib/components/ui/sheet/SheetHeader.svelte";
	import SheetTitle from "$lib/components/ui/sheet/SheetTitle.svelte";
	import SheetDescription from "$lib/components/ui/sheet/SheetDescription.svelte";
	import { Button } from "$lib/components/ui/button/index.js";
	import { Separator } from "$lib/components/ui/separator/index.js";
	import { Badge } from "$lib/components/ui/badge/index.js";
	import {
		Sun,
		Moon,
		Monitor,
		Globe,
		Send,
		ExternalLink,
		Share2,
		X,
	} from "@lucide/svelte";
	import GitHubIcon from "$lib/components/icons/GitHub.svelte";
	import XBrandIcon from "$lib/components/icons/XBrand.svelte";
	import { videoState, ntpClient, getThemeMode, setThemeMode, pause, play } from "$lib/stores.svelte";
	import type { ThemeMode } from "$lib/stores.svelte";
	import {
		Root as TooltipRoot,
		Trigger as TooltipTrigger,
		Provider as TooltipProvider,
	} from "$lib/components/ui/tooltip/index.js";
	import TooltipContent from "$lib/components/ui/tooltip/TooltipContent.svelte";

	let { onClose }: { onClose: () => void } = $props();

	let open = $derived(videoState.isSettingsOpen);
	let currentTheme = $derived(getThemeMode());

	/** Matching Swift: .sheet(onDismiss: { viewModel.syncVideo() }) */
	function setOpen(val: boolean) {
		videoState.isSettingsOpen = val;
		if (!val) {
			onClose();
		}
	}

	function changeTheme(mode: ThemeMode) {
		setThemeMode(mode);
	}

	function share() {
		if (navigator.share) {
			navigator.share({
				title: "Epic Sax Gandalf",
				text: "Behold the glory of infinite Gandalf!",
				url: "https://youtu.be/BBGEG21CGo0",
			});
		} else {
			navigator.clipboard.writeText("https://youtu.be/BBGEG21CGo0");
		}
	}
</script>

<TooltipProvider delayDuration={300}>
	<SheetRoot bind:open onOpenChange={setOpen}>
		<SheetContent side="bottom" class="max-h-[70vh] overflow-y-auto">
			<div class="mx-auto max-w-sm">
				<SheetHeader>
					<div class="flex items-center justify-between">
						<div class="flex items-center gap-2">
							<Badge
								variant={ntpClient.isSynced ? "secondary" : "outline"}
								class={ntpClient.isSynced
									? "bg-green-500/20 text-green-400 border-green-500/30 hover:bg-green-500/30"
									: "bg-muted text-muted-foreground"
								}
							>
								<span class="mr-1">●</span>
								{ntpClient.isSynced ? "NTP synced" : "Device time"}
							</Badge>
						</div>
						<SheetClose>
							<Button variant="ghost" size="icon" class="h-8 w-8">
								<X size={16} />
							</Button>
						</SheetClose>
					</div>
					<SheetTitle class="text-lg font-bold">
						Behold the glory of infinite Gandalf!
					</SheetTitle>
					<SheetDescription class="text-primary font-semibold text-sm">
						Billions must be entertained!
					</SheetDescription>
				</SheetHeader>

				<div class="mt-3 space-y-3 pb-3">
					<!-- Playback -->
					<div>
						<h3 class="text-sm font-medium mb-2">Playback</h3>
						<div class="flex gap-2">
							<Button
								variant={videoState.pauseOnSheetOpen ? "default" : "outline"}
								size="sm"
								onclick={() => {
									videoState.pauseOnSheetOpen = true;
									pause();
								}}
								class="flex-1"
							>
								Pause on Open
							</Button>
							<Button
								variant={!videoState.pauseOnSheetOpen ? "default" : "outline"}
								size="sm"
								onclick={() => {
									videoState.pauseOnSheetOpen = false;
									play();
								}}
								class="flex-1"
							>
								Keep Playing
							</Button>
						</div>
						<p class="text-muted-foreground text-xs mt-1.5">
							Sets default behavior when opening this panel
						</p>
					</div>

					<Separator />

					<!-- Theme Selection -->
					<div>
						<h3 class="text-sm font-medium mb-2">Theme</h3>
						<div class="flex gap-2">
							<Button
								variant={currentTheme === "light" ? "default" : "outline"}
								size="sm"
								onclick={() => changeTheme("light")}
								class="flex-1 gap-2"
							>
								<Sun size={16} />
								Light
							</Button>
							<Button
								variant={currentTheme === "dark" ? "default" : "outline"}
								size="sm"
								onclick={() => changeTheme("dark")}
								class="flex-1 gap-2"
							>
								<Moon size={16} />
								Dark
							</Button>
							<Button
								variant={currentTheme === "system" ? "default" : "outline"}
								size="sm"
								onclick={() => changeTheme("system")}
								class="flex-1 gap-2"
							>
								<Monitor size={16} />
								System
							</Button>
						</div>
					</div>

					<Separator />

					<!-- Developer Info -->
					<div>
						<h3 class="text-sm font-medium mb-2">Developer</h3>
						<p class="text-muted-foreground text-sm mb-2">hmziqrs</p>
						<div class="flex gap-2">
							<TooltipRoot>
								<TooltipTrigger>
									{#snippet child({ props })}
										<Button
											{...props}
											variant="outline"
											size="icon"
											onclick={() => window.open("https://hmziq.rs", "_blank")}
											aria-label="Website"
										>
											<Globe size={16} />
										</Button>
									{/snippet}
								</TooltipTrigger>
								<TooltipContent>Website</TooltipContent>
							</TooltipRoot>
							<TooltipRoot>
								<TooltipTrigger>
									{#snippet child({ props })}
										<Button
											{...props}
											variant="outline"
											size="icon"
											onclick={() => window.open("https://github.com/hmziqrs", "_blank")}
											aria-label="GitHub"
										>
											<GitHubIcon size={16} />
										</Button>
									{/snippet}
								</TooltipTrigger>
								<TooltipContent>GitHub</TooltipContent>
							</TooltipRoot>
							<TooltipRoot>
								<TooltipTrigger>
									{#snippet child({ props })}
										<Button
											{...props}
											variant="outline"
											size="icon"
											onclick={() => window.open("https://x.com/hmziqrs", "_blank")}
											aria-label="X"
										>
											<XBrandIcon size={16} />
										</Button>
									{/snippet}
								</TooltipTrigger>
								<TooltipContent>X (Twitter)</TooltipContent>
							</TooltipRoot>
							<TooltipRoot>
								<TooltipTrigger>
									{#snippet child({ props })}
										<Button
											{...props}
											variant="outline"
											size="icon"
											onclick={() => window.open("https://t.me/hmziqrs", "_blank")}
											aria-label="Telegram"
										>
											<Send size={16} />
										</Button>
									{/snippet}
								</TooltipTrigger>
								<TooltipContent>Telegram</TooltipContent>
							</TooltipRoot>
						</div>
					</div>

					<Separator />

					<!-- Video Source -->
					<div>
						<h3 class="text-sm font-medium mb-2">Video Source</h3>
						<div class="flex gap-2">
							<Button
								variant="outline"
								size="sm"
								onclick={() => window.open("https://youtu.be/BBGEG21CGo0", "_blank")}
								class="flex-1 gap-2"
							>
								<ExternalLink size={16} />
								Original Video
							</Button>
							<Button
								variant="outline"
								size="sm"
								onclick={share}
								class="flex-1 gap-2"
							>
								<Share2 size={16} />
								Share
							</Button>
						</div>
					</div>
				</div>
			</div>
		</SheetContent>
	</SheetRoot>
</TooltipProvider>
