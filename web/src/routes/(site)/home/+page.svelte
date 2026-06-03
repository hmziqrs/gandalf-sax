<script lang="ts">
	import { Button } from "$lib/components/ui/button";
	import { Play, Music, Repeat, Clock, Smartphone } from "@lucide/svelte";
	import Seo from "$lib/components/Seo.svelte";
	import { pages } from "$lib/seo";

	const features = [
		{
			icon: Repeat,
			title: "Infinite Loop",
			body: "Gandalf never stops playing. An endless, perfectly timed loop that keeps going and going and going.",
		},
		{
			icon: Clock,
			title: "NTP Synced",
			body: "Everyone sees the same frame at the same time. Billions of viewers, perfectly synchronized via network time protocol.",
		},
		{
			icon: Smartphone,
			title: "Cross Platform",
			body: "Available on web, macOS, and iOS. Entertain yourself on any device.",
		},
	];
</script>

<Seo seo={pages['/home']} />

<!-- Hero -->
<section
	class="relative isolate flex min-h-[calc(100vh-3.5rem)] flex-col items-center justify-center overflow-hidden px-4 text-center"
>
	<div class="pointer-events-none absolute inset-0 -z-10 bg-grid"></div>
	<div
		class="pointer-events-none absolute left-1/2 top-1/3 -z-10 h-[32rem] w-[32rem] max-w-full -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary/25 blur-[140px]"
	></div>

	<div class="mx-auto max-w-3xl">
		<div
			class="mx-auto flex w-fit items-center gap-2 rounded-full border border-border/70 bg-card/60 px-4 py-1.5 font-mono text-xs uppercase tracking-[0.2em] text-muted-foreground backdrop-blur"
		>
			<span class="relative flex h-2 w-2">
				<span
					class="absolute inline-flex h-full w-full animate-ping rounded-full bg-primary opacity-75"
				></span>
				<span class="relative inline-flex h-2 w-2 rounded-full bg-primary"></span>
			</span>
			Playing worldwide
		</div>

		<h1 class="mt-6 text-4xl font-bold tracking-tight md:text-6xl">
			Behold the Glory of
			<span class="text-primary">Infinite Gandalf</span>
		</h1>
		<p class="mx-auto mt-5 max-w-xl text-lg text-muted-foreground md:text-xl">
			Billions must be entertained! Watch Gandalf play the saxophone forever,
			perfectly synchronized across the world.
		</p>
		<div class="mt-9 flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
			<a href="/">
				<Button size="lg" class="gap-2 text-base">
					<Play size={20} />
					Watch Now
				</Button>
			</a>
			<a href="/about">
				<Button variant="outline" size="lg" class="text-base">
					Learn More
				</Button>
			</a>
		</div>
	</div>
</section>

<!-- Features -->
<section class="border-t border-border bg-card/40 px-4 py-20">
	<div class="container mx-auto max-w-5xl">
		<div
			class="flex items-center justify-center gap-3 font-mono text-xs font-medium uppercase tracking-[0.25em] text-primary"
		>
			<span class="h-px w-8 bg-primary/40"></span>
			Why Epic Sax Gandalf
			<span class="h-px w-8 bg-primary/40"></span>
		</div>

		<div class="mt-12 grid gap-px overflow-hidden rounded-xl border border-border bg-border sm:grid-cols-3">
			{#each features as feature, i}
				<div class="group bg-card p-7 transition-colors hover:bg-accent/40">
					<div class="flex items-center justify-between">
						<div
							class="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary transition-colors group-hover:bg-primary group-hover:text-primary-foreground"
						>
							<feature.icon size={20} />
						</div>
						<span class="font-mono text-xs text-muted-foreground">
							0{i + 1}
						</span>
					</div>
					<h3 class="mt-5 font-semibold">{feature.title}</h3>
					<p class="mt-2 text-sm leading-relaxed text-muted-foreground">
						{feature.body}
					</p>
				</div>
			{/each}
		</div>
	</div>
</section>

<!-- CTA -->
<section class="px-4 py-20 text-center">
	<div class="mx-auto max-w-2xl">
		<h2 class="text-2xl font-bold md:text-3xl">Ready to be entertained?</h2>
		<p class="mt-3 text-muted-foreground">
			The greatest saxophone performance in Middle-earth awaits.
		</p>
		<a href="/" class="mt-7 inline-block">
			<Button size="lg" class="gap-2 text-base">
				<Music size={20} />
				Experience the Sax
			</Button>
		</a>
	</div>
</section>
