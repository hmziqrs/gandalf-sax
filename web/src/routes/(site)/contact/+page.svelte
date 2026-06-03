<script lang="ts">
	import GitHubIcon from "$lib/components/icons/GitHub.svelte";
	import XBrandIcon from "$lib/components/icons/XBrand.svelte";
	import { Globe } from "@lucide/svelte";
	import Seo from "$lib/components/Seo.svelte";
	import { pages } from "$lib/seo";
</script>

<svelte:head>
	<title>Contact — Epic Sax Gandalf</title>
	<meta name="description" content="Get in touch with the creator of Epic Sax Gandalf." />
</svelte:head>

<div class="mx-auto max-w-3xl px-4 py-12">
	<h1 class="text-3xl font-bold md:text-4xl">Get in Touch</h1>
	<p class="mt-3 text-muted-foreground">
		Want to reach out? Find me on these platforms.
	</p>

	<div class="mt-8 grid gap-4 sm:grid-cols-2">
		<a
			href="https://hmziq.rs"
			target="_blank"
			rel="noopener noreferrer"
			class="flex items-center gap-4 rounded-lg border border-border bg-card p-4 transition-colors hover:bg-accent"
		>
			<div class="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
				<Globe size={20} class="text-primary" />
			</div>
			<div>
				<p class="font-medium">Website</p>
				<p class="text-sm text-muted-foreground">hmziq.rs</p>
			</div>
		</a>

		<a
			href="https://github.com/hmziqrs"
			target="_blank"
			rel="noopener noreferrer"
			class="flex items-center gap-4 rounded-lg border border-border bg-card p-4 transition-colors hover:bg-accent"
		>
			<div class="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
				<GitHubIcon size={20} class="text-primary" />
			</div>
			<div>
				<p class="font-medium">GitHub</p>
				<p class="text-sm text-muted-foreground">github.com/hmziqrs</p>
			</div>
		</a>

		<a
			href="https://x.com/hmziqrs"
			target="_blank"
			rel="noopener noreferrer"
			class="flex items-center gap-4 rounded-lg border border-border bg-card p-4 transition-colors hover:bg-accent"
		>
			<div class="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
				<XBrandIcon size={20} class="text-primary" />
			</div>
			<div>
				<p class="font-medium">X (Twitter)</p>
				<p class="text-sm text-muted-foreground">@hmziqrs</p>
			</div>
		</a>

	</div>

	<p class="mt-8 text-sm text-muted-foreground">
		For bug reports or feature requests, please open an issue on
		<a
			href="https://github.com/hmziqrs/gandalf-sax/issues"
			target="_blank"
			rel="noopener noreferrer"
			class="font-medium text-primary transition-colors hover:text-primary/80"
		>
			GitHub Issues
		</a>.
	</p>
</div>
