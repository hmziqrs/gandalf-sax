<script lang="ts">
	import { cn } from "$lib/utils";
	import { badgeVariants, type BadgeProps } from "./index.js";

	let {
		variant = "default",
		class: className,
		children,
		...restProps
	}: BadgeProps = $props();
</script>

<div class={cn(badgeVariants({ variant }), className)} {...restProps}>
	{@render children?.()}
</div>
