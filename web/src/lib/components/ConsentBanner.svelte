<script lang="ts">
	import { Button } from "$lib/components/ui/button";

	let visible = $state(false);

	$effect(() => {
		if (typeof window === "undefined") return;
		// Show banner only if the user hasn't dismissed it before
		const dismissed = localStorage.getItem("gandalf_consent_dismissed");
		if (!dismissed) {
			visible = true;
		}
	});

	function dismiss() {
		visible = false;
		if (typeof window !== "undefined") {
			localStorage.setItem("gandalf_consent_dismissed", "true");
		}
	}
</script>

{#if visible}
	<div
		class="fixed bottom-0 left-0 right-0 z-50 border-t border-border bg-background/95 px-4 py-3 backdrop-blur-sm"
		role="banner"
		aria-label="Storage consent"
	>
		<div class="mx-auto flex max-w-3xl flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
			<p class="text-sm text-muted-foreground">
				This site uses
				<strong class="text-foreground">localStorage</strong>
				for your theme preference and
				<strong class="text-foreground">Firebase Analytics</strong>
				(Google Analytics) with cookies to measure anonymous, aggregate usage.
				No accounts, no ads, no selling of data.
				<a
					href="/privacy"
					class="font-medium text-primary transition-colors hover:text-primary/80"
				>
					Privacy Policy
				</a>
			</p>
			<div class="flex shrink-0 gap-2">
				<Button variant="outline" size="sm" onclick={dismiss}>
					Got it
				</Button>
			</div>
		</div>
	</div>
{/if}
