<script lang="ts">
	import { cn } from "$lib/utils";
	import type { SeparatorProps } from "./index.js";

	let {
		orientation = "horizontal",
		decorative = true,
		class: className,
		...restProps
	}: SeparatorProps = $props();
</script>

<div
	role={decorative ? "none" : "separator"}
	aria-orientation={!decorative ? orientation : undefined}
	class={cn(
		"shrink-0 bg-border",
		orientation === "horizontal" ? "h-[1px] w-full" : "h-full w-[1px]",
		className
	)}
	{...restProps}
></div>
