<script lang="ts">
	import { cn } from "$lib/utils";
	import type { Snippet } from "svelte";

	type Props = {
		class?: string;
		children?: Snippet;
	};

	let { class: className, children }: Props = $props();
</script>

<div class={cn("flex flex-col-reverse sm:flex-row sm:justify-end sm:gap-2", className)}>
	{@render children?.()}
</div>
