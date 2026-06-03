<script lang="ts">
	import { Separator } from "$lib/components/ui/separator";
	import GitHubIcon from "$lib/components/icons/GitHub.svelte";
	import XBrandIcon from "$lib/components/icons/XBrand.svelte";
	import { Globe } from "@lucide/svelte";
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

			<p class="text-center text-xs text-muted-foreground">
				&copy; 2026 <span class="text-shimmer font-medium">hmziqrs</span>. All rights reserved.
			</p>
		</div>
	</div>
</footer>
