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
	import { videoState, themeMode, ntpClient } from "$lib/stores";
	import type { ThemeMode } from "$lib/stores";

	let open = $derived($videoState.isSettingsOpen);

	function setOpen(val: boolean) {
		videoState.update((s) => ({ ...s, isSettingsOpen: val }));
		if (!val) {
			videoState.update((s) => ({ ...s, isPlaying: true }));
		}
	}

	function setTheme(mode: ThemeMode) {
		themeMode.set(mode);
		applyTheme(mode);
	}

	function applyTheme(mode: ThemeMode) {
		if (typeof document === "undefined") return;
		const root = document.documentElement;
		let resolved = mode;
		if (mode === "system") {
			resolved = window.matchMedia("(prefers-color-scheme: dark)").matches
				? "dark"
				: "light";
		}
		root.classList.toggle("dark", resolved === "dark");
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

	// Apply theme on mount
	$effect(() => {
		applyTheme($themeMode);
	});
</script>

<SheetRoot bind:open onOpenChange={setOpen}>
	<SheetContent side="bottom" class="max-h-[70vh] overflow-y-auto rounded-t-2xl">
		<div class="mx-auto max-w-md">
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

			<div class="mt-6 space-y-6 pb-6">
				<!-- Theme Selection -->
				<div>
					<h3 class="text-sm font-medium mb-3">Theme</h3>
					<div class="flex gap-2">
						<Button
							variant={$themeMode === "light" ? "default" : "outline"}
							size="sm"
							onclick={() => setTheme("light")}
							class="flex-1 gap-2"
						>
							<Sun size={16} />
							Light
						</Button>
						<Button
							variant={$themeMode === "dark" ? "default" : "outline"}
							size="sm"
							onclick={() => setTheme("dark")}
							class="flex-1 gap-2"
						>
							<Moon size={16} />
							Dark
						</Button>
						<Button
							variant={$themeMode === "system" ? "default" : "outline"}
							size="sm"
							onclick={() => setTheme("system")}
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
					<h3 class="text-sm font-medium mb-3">Developer</h3>
					<p class="text-muted-foreground text-sm mb-3">hmziqrs</p>
					<div class="flex gap-2">
						<Button
							variant="outline"
							size="icon"
							onclick={() => window.open("https://hmziq.rs", "_blank")}
							aria-label="Website"
						>
							<Globe size={16} />
						</Button>
						<Button
							variant="outline"
							size="icon"
							onclick={() => window.open("https://github.com/hmziqrs", "_blank")}
							aria-label="GitHub"
						>
							<GitHubIcon size={16} />
						</Button>
						<Button
							variant="outline"
							size="icon"
							onclick={() => window.open("https://x.com/hmziqrs", "_blank")}
							aria-label="X"
						>
							<XBrandIcon size={16} />
						</Button>
						<Button
							variant="outline"
							size="icon"
							onclick={() => window.open("https://t.me/hmziqrs", "_blank")}
							aria-label="Telegram"
						>
							<Send size={16} />
						</Button>
					</div>
				</div>

				<Separator />

				<!-- Video Source -->
				<div>
					<h3 class="text-sm font-medium mb-3">Video Source</h3>
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
