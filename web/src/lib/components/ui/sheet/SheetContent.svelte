<script lang="ts">
	import { Dialog as SheetPrimitive } from "bits-ui";
	import { cn } from "$lib/utils";
	import SheetOverlay from "./SheetOverlay.svelte";
	import type { Snippet } from "svelte";

	type Props = SheetPrimitive.ContentProps & {
		side?: "top" | "right" | "bottom" | "left";
		children?: Snippet;
		class?: string;
	};

	let {
		side = "right",
		class: className,
		children,
		...restProps
	}: Props = $props();

	const sideClasses = {
		top: "inset-x-0 top-0 border-b data-[state=closed]:slide-out-to-top data-[state=open]:slide-in-from-top",
		bottom: "inset-x-0 bottom-0 border-t data-[state=closed]:slide-out-to-bottom data-[state=open]:slide-in-from-bottom mx-auto sm:max-w-lg sm:rounded-t-2xl",
		left: "inset-y-0 left-0 h-full w-3/4 border-r data-[state=closed]:slide-out-to-left data-[state=open]:slide-in-from-left sm:max-w-sm",
		right: "inset-y-0 right-0 h-full w-3/4 border-l data-[state=closed]:slide-out-to-right data-[state=open]:slide-in-from-right sm:max-w-sm",
	};
</script>

<SheetOverlay />
<SheetPrimitive.Content
	class={cn(
		"fixed z-50 gap-4 bg-background p-4 sm:p-6 shadow-lg transition ease-in-out data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:duration-300 data-[state=open]:duration-500",
		sideClasses[side],
		className
	)}
	{...restProps}
>
	{@render children?.()}
</SheetPrimitive.Content>
