<script lang="ts">
	import { Button } from "$lib/components/ui/button";
	import GitHubIcon from "$lib/components/icons/GitHub.svelte";
	import XBrandIcon from "$lib/components/icons/XBrand.svelte";
	import {
		Play,
		Music,
		Repeat,
		Clock,
		Smartphone,
		Globe,
	} from "@lucide/svelte";
	import Seo from "$lib/components/Seo.svelte";
	import { pages } from "$lib/seo";
</script>

<Seo seo={pages['/home']} />

<!-- Hero -->
<section
	class="flex min-h-[calc(100vh-3.5rem)] flex-col items-center justify-center px-4 text-center"
>
	<div class="mx-auto max-w-3xl">
		<h1
			class="text-4xl font-bold tracking-tight md:text-6xl"
		>
			Behold the Glory of
			<span class="text-primary">Infinite Gandalf</span>
		</h1>
		<p class="mt-4 text-lg text-muted-foreground md:text-xl">
			Billions must be entertained! Watch Gandalf play the saxophone forever,
			perfectly synchronized across the world.
		</p>
		<div class="mt-8 flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
			<Button size="lg" href="/" class="gap-2 text-base">
				<Play size={20} />
				Watch Now
			</Button>
			<Button variant="outline" size="lg" href="/about" class="text-base">
				Learn More
			</Button>
		</div>
	</div>
</section>

<!-- Features -->
<section class="border-t border-border bg-card/50 px-4 py-16">
	<div class="container mx-auto max-w-5xl">
		<h2 class="mb-10 text-center text-2xl font-bold md:text-3xl">
			Why Epic Sax Gandalf?
		</h2>
		<div class="grid gap-6 md:grid-cols-3">
			<!-- Infinite Loop -->
			<div class="rounded-lg border border-border bg-card p-6">
				<div
					class="mb-4 flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10"
				>
					<Repeat size={20} class="text-primary" />
				</div>
				<h3 class="mb-2 font-semibold">Infinite Loop</h3>
				<p class="text-sm text-muted-foreground">
					Gandalf never stops playing. An endless, perfectly timed loop that
					keeps going and going and going.
				</p>
			</div>

			<!-- NTP Synced -->
			<div class="rounded-lg border border-border bg-card p-6">
				<div
					class="mb-4 flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10"
				>
					<Clock size={20} class="text-primary" />
				</div>
				<h3 class="mb-2 font-semibold">NTP Synced</h3>
				<p class="text-sm text-muted-foreground">
					Everyone sees the same frame at the same time. Billions of viewers,
					perfectly synchronized via network time protocol.
				</p>
			</div>

			<!-- Cross Platform -->
			<div class="rounded-lg border border-border bg-card p-6">
				<div
					class="mb-4 flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10"
				>
					<Smartphone size={20} class="text-primary" />
				</div>
				<h3 class="mb-2 font-semibold">Cross Platform</h3>
				<p class="text-sm text-muted-foreground">
					Available on web, macOS, and iOS. Entertain yourself on any
					device.
				</p>
			</div>
		</div>
	</div>
</section>

<!-- CTA -->
<section class="px-4 py-16 text-center">
	<div class="mx-auto max-w-2xl">
		<h2 class="text-2xl font-bold md:text-3xl">Ready to be entertained?</h2>
		<p class="mt-3 text-muted-foreground">
			The greatest saxophone performance in Middle-earth awaits.
		</p>
		<Button size="lg" href="/" class="mt-6 gap-2 text-base">
			<Music size={20} />
			Experience the Sax
		</Button>
	</div>
</section>

<!-- Developer credit -->
<section class="border-t border-border px-4 py-10">
	<div class="mx-auto max-w-2xl text-center">
		<p class="text-sm text-muted-foreground">
			Built by
			<a
				href="https://hmziq.rs"
				target="_blank"
				rel="noopener noreferrer"
				class="font-medium text-foreground transition-colors hover:text-primary"
			>
				hmziqrs
			</a>
		</p>
		<div class="mt-3 flex items-center justify-center gap-3">
			<a
				href="https://hmziq.rs"
				target="_blank"
				rel="noopener noreferrer"
				class="text-muted-foreground transition-colors hover:text-foreground"
				aria-label="Website"
			>
				<Globe size={18} />
			</a>
			<a
				href="https://github.com/hmziqrs"
				target="_blank"
				rel="noopener noreferrer"
				class="text-muted-foreground transition-colors hover:text-foreground"
				aria-label="GitHub"
			>
				<GitHubIcon size={18} />
			</a>
			<a
				href="https://x.com/hmziqrs"
				target="_blank"
				rel="noopener noreferrer"
				class="text-muted-foreground transition-colors hover:text-foreground"
				aria-label="X (Twitter)"
			>
				<XBrandIcon size={18} />
			</a>
		</div>
	</div>
</section>
