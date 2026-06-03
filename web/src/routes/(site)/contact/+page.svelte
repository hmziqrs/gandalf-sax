<script lang="ts">
	import GitHubIcon from "$lib/components/icons/GitHub.svelte";
	import XBrandIcon from "$lib/components/icons/XBrand.svelte";
	import { Globe } from "@lucide/svelte";
	import Seo from "$lib/components/Seo.svelte";
	import { pages } from "$lib/seo";
</script>

<Seo seo={pages['/contact']} />

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

	<div class="mt-10">
		<h2 class="text-xl font-semibold">Found a Bug? Got an Idea?</h2>
		<p class="mt-2 text-muted-foreground">
			The fastest way to reach me is through
			<a
				href="https://github.com/hmziqrs/gandalf-sax/issues"
				target="_blank"
				rel="noopener noreferrer"
				class="font-medium text-primary transition-colors hover:text-primary/80"
			>
				GitHub Issues
			</a>.
			I try to respond within a day or two — though if I'm deep in a
			sax-remix rabbit hole, it might take a beat longer.
		</p>
	</div>

	<div class="mt-10">
		<h2 class="text-xl font-semibold">FAQ</h2>

		<div class="mt-4 space-y-5">
			<div>
				<h3 class="font-medium">Can I use this in my project?</h3>
				<p class="mt-1 text-sm text-muted-foreground">
					Yes — the code is open source under the MIT license. Fork it,
					remix it, deploy your own synchronized meme. Just don't blame
					me if it becomes your most-used project.
				</p>
			</div>

			<div>
				<h3 class="font-medium">How do I report a bug?</h3>
				<p class="mt-1 text-sm text-muted-foreground">
					Open an issue on
					<a
						href="https://github.com/hmziqrs/gandalf-sax/issues"
						target="_blank"
						rel="noopener noreferrer"
						class="font-medium text-primary transition-colors hover:text-primary/80"
					>
						GitHub
					</a>
					with steps to reproduce. Screenshots help. Dramatic
					re-enactments are optional but appreciated.
				</p>
			</div>

			<div>
				<h3 class="font-medium">Is the video really synchronized for everyone?</h3>
				<p class="mt-1 text-sm text-muted-foreground">
					Yes. The player uses NTP-based time sync so every viewer sees
					the same frame at the same moment, worldwide. Check out the
					<a href="/about" class="font-medium text-primary transition-colors hover:text-primary/80">about page</a>
					for the full technical rundown.
				</p>
			</div>
		</div>
	</div>

	<div class="mt-10 rounded-lg border border-border bg-muted/40 p-5">
		<p class="text-sm text-muted-foreground">
			While you're here, check out the
			<a href="/play" class="font-medium text-primary transition-colors hover:text-primary/80">saxophone loop</a>
			or learn more
			<a href="/about" class="font-medium text-primary transition-colors hover:text-primary/80">about the project</a>.
		</p>
	</div>
</div>
