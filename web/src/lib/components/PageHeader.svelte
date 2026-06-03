<script lang="ts">
	let {
		eyebrow,
		title,
		lead,
		meta,
	}: {
		eyebrow: string;
		title: string;
		lead?: string;
		meta?: string;
	} = $props();
</script>

<header class="relative isolate overflow-hidden border-b border-border/60">
	<div class="pointer-events-none absolute inset-0 -z-10 bg-grid opacity-60"></div>
	<div
		class="pointer-events-none absolute -top-24 left-1/2 -z-10 h-72 w-[36rem] max-w-full -translate-x-1/2 rounded-full bg-primary/20 blur-[120px]"
	></div>

	<div class="mx-auto max-w-3xl px-4 pb-12 pt-16 md:pt-20">
		<div
			class="flex items-center gap-3 font-mono text-xs font-medium uppercase tracking-[0.25em] text-primary"
		>
			<span class="h-px w-8 bg-primary/40"></span>
			{eyebrow}
		</div>

		<h1 class="mt-5 text-4xl font-bold tracking-tight md:text-5xl">{title}</h1>

		{#if lead}
			<p class="mt-4 max-w-2xl text-lg leading-relaxed text-muted-foreground">
				{lead}
			</p>
		{/if}

		{#if meta}
			<p class="mt-4 font-mono text-xs text-muted-foreground">{meta}</p>
		{/if}
	</div>
</header>
