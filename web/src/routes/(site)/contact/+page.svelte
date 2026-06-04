<script lang="ts">
	import GitHubIcon from "$lib/components/icons/GitHub.svelte";
	import XBrandIcon from "$lib/components/icons/XBrand.svelte";
	import { Globe, ArrowUpRight } from "@lucide/svelte";
	import Seo from "$lib/components/Seo.svelte";
	import PageHeader from "$lib/components/PageHeader.svelte";
	import { pages } from "$lib/seo";
	import { logClickSocialLink } from "$lib/analytics";

	const links = [
		{ icon: Globe, label: "Website", handle: "hmziq.rs", href: "https://hmziq.rs" },
		{ icon: Globe, label: "Website", handle: "hmziq.xyz", href: "https://hmziq.xyz" },
		{
			icon: GitHubIcon,
			label: "GitHub",
			handle: "github.com/hmziqrs",
			href: "https://github.com/hmziqrs",
		},
		{
			icon: XBrandIcon,
			label: "X (Twitter)",
			handle: "@hmziqrs",
			href: "https://x.com/hmziqrs",
		},
	];
</script>

<Seo seo={pages['/contact']} />

<PageHeader
	eyebrow="Contact"
	title="Get in Touch"
	lead="Want to reach out? Find me on these platforms."
/>

<div class="mx-auto max-w-3xl px-4 py-14">
	<div class="grid gap-4 sm:grid-cols-2">
		{#each links as link}
			<a
				href={link.href}
				target="_blank"
				rel="noopener noreferrer"
				onclick={() => logClickSocialLink(link.handle, link.href)}
				class="group relative flex flex-col gap-4 rounded-xl border border-border bg-card p-5 transition-colors hover:border-primary/40 hover:bg-accent/40"
			>
				<div class="flex items-center justify-between">
					<div
						class="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary transition-colors group-hover:bg-primary group-hover:text-primary-foreground"
					>
						<link.icon size={20} />
					</div>
					<ArrowUpRight
						size={18}
						class="text-muted-foreground/50 transition-all group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-primary"
					/>
				</div>
				<div>
					<p class="font-medium">{link.label}</p>
					<p class="font-mono text-xs text-muted-foreground">{link.handle}</p>
				</div>
			</a>
		{/each}
	</div>

	<div class="mt-12 space-y-10">
		<section class="border-l-2 border-primary/30 pl-6">
			<h2 class="text-xl font-semibold">Found a Bug? Got an Idea?</h2>
			<p class="mt-2 leading-relaxed text-muted-foreground">
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
		</section>

		<section class="border-l-2 border-primary/30 pl-6">
			<h2 class="text-xl font-semibold">Quick Answers</h2>
			<div class="mt-4 space-y-5">
				<div>
					<h3 class="font-medium">Can I use this in my project?</h3>
					<p class="mt-1 text-sm leading-relaxed text-muted-foreground">
						Yes — the code is open source under the MIT license. Fork it,
						remix it, deploy your own synchronized meme. Just don't blame
						me if it becomes your most-used project.
					</p>
				</div>

				<div>
					<h3 class="font-medium">How do I report a bug?</h3>
					<p class="mt-1 text-sm leading-relaxed text-muted-foreground">
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
					<p class="mt-1 text-sm leading-relaxed text-muted-foreground">
						Yes. The player uses NTP-based time sync so every viewer sees
						the same frame at the same moment, worldwide. Check out the
						<a href="/about" class="font-medium text-primary transition-colors hover:text-primary/80">about page</a>
						for the full technical rundown.
					</p>
				</div>
			</div>
		</section>
	</div>

	<div class="mt-12 rounded-xl border border-border bg-muted/40 p-5">
		<p class="text-sm text-muted-foreground">
			While you're here, check out the
			<a href="/" class="font-medium text-primary transition-colors hover:text-primary/80">saxophone loop</a>
			or learn more
			<a href="/about" class="font-medium text-primary transition-colors hover:text-primary/80">about the project</a>.
		</p>
	</div>
</div>
