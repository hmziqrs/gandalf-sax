<script lang="ts">
	import { Separator } from "$lib/components/ui/separator";
	import GitHubIcon from "$lib/components/icons/GitHub.svelte";
	import XBrandIcon from "$lib/components/icons/XBrand.svelte";
	import { Globe } from "@lucide/svelte";
	import { logClickSocialLink } from "$lib/analytics";
</script>

<footer class="border-t border-border bg-background">
	<div class="container mx-auto px-4 py-8">
		<div class="grid grid-cols-1 gap-8 md:grid-cols-3">
			<!-- Brand -->
			<div>
				<h3 class="text-lg font-bold">Epic Sax Gandalf</h3>
				<p class="mt-1 text-sm text-muted-foreground">Billions must be entertained!</p>
			</div>

			<!-- Explore links -->
			<div>
				<h4 class="mb-3 text-sm font-semibold">Explore</h4>
				<div class="flex flex-col gap-2">
					<a
						href="/"
						class="text-sm text-muted-foreground transition-colors hover:text-foreground"
					>
						Watch
					</a>
					<a
						href="/about"
						class="text-sm text-muted-foreground transition-colors hover:text-foreground"
					>
						About
					</a>
					<a
						href="/faq"
						class="text-sm text-muted-foreground transition-colors hover:text-foreground"
					>
						FAQ
					</a>
				</div>
			</div>

			<!-- Legal links -->
			<div>
				<h4 class="mb-3 text-sm font-semibold">Legal</h4>
				<div class="flex flex-col gap-2">
					<a
						href="/privacy"
						class="text-sm text-muted-foreground transition-colors hover:text-foreground"
					>
						Privacy Policy
					</a>
					<a
						href="/terms"
						class="text-sm text-muted-foreground transition-colors hover:text-foreground"
					>
						Terms of Service
					</a>
				</div>
			</div>

		</div>

		<Separator class="my-6" />

		<div class="flex flex-col items-center gap-4">
			<div class="flex gap-5">
				<a
					href="https://hmziq.rs?ref=gandalf.hmziq.xyz"
					target="_blank"
					rel="noopener noreferrer"
					onclick={() => logClickSocialLink("hmziq.rs", "https://hmziq.rs?ref=gandalf.hmziq.xyz")}
					class="text-muted-foreground transition-colors hover:text-foreground"
					aria-label="Website"
				>
					<Globe size={18} />
				</a>
				<a
					href="https://hmziq.xyz?ref=gandalf.hmziq.xyz"
					target="_blank"
					rel="noopener noreferrer"
					onclick={() => logClickSocialLink("hmziq.xyz", "https://hmziq.xyz?ref=gandalf.hmziq.xyz")}
					class="text-muted-foreground transition-colors hover:text-foreground"
					aria-label="hmziq.xyz"
				>
					<Globe size={18} />
				</a>
				<a
					href="https://github.com/hmziqrs?ref=gandalf.hmziq.xyz"
					target="_blank"
					rel="noopener noreferrer"
					onclick={() => logClickSocialLink("github", "https://github.com/hmziqrs?ref=gandalf.hmziq.xyz")}
					class="text-muted-foreground transition-colors hover:text-foreground"
					aria-label="GitHub"
				>
					<GitHubIcon size={18} />
				</a>
				<a
					href="https://x.com/hmziqrs?ref=gandalf.hmziq.xyz"
					target="_blank"
					rel="noopener noreferrer"
					onclick={() => logClickSocialLink("x", "https://x.com/hmziqrs?ref=gandalf.hmziq.xyz")}
					class="text-muted-foreground transition-colors hover:text-foreground"
					aria-label="X (Twitter)"
				>
					<XBrandIcon size={18} />
				</a>
			</div>

			<p class="text-center text-xs text-muted-foreground">
				&copy; 2026 <a href="https://hmziq.rs?ref=gandalf.hmziq.xyz" target="_blank" rel="noopener noreferrer" class="text-shimmer font-medium hover:text-foreground">hmziqrs</a>. All rights reserved.
			</p>
			<p class="text-center text-xs text-muted-foreground">
				Built with <a href="https://kit.svelte.dev?ref=gandalf.hmziq.xyz" target="_blank" rel="noopener noreferrer" class="underline transition-colors hover:text-foreground">SvelteKit 5</a>
				and deployed by <a href="https://pages.cloudflare.com?ref=gandalf.hmziq.xyz" target="_blank" rel="noopener noreferrer" class="underline transition-colors hover:text-foreground">Cloudflare Pages</a>.
			</p>
		</div>
	</div>
</footer>
