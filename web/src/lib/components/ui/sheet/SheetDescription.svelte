<script lang="ts">
	import { Dialog as SheetPrimitive } from "bits-ui";
	import { cn } from "$lib/utils";
	import type { Snippet } from "svelte";

	type Props = SheetPrimitive.DescriptionProps & {
		children?: Snippet;
		class?: string;
	};

	let { class: className, children, ...restProps }: Props = $props();
</script>

<SheetPrimitive.Description
	class={cn("text-sm text-muted-foreground", className)}
	{...restProps}
>
	{@render children?.()}
</SheetPrimitive.Description>
