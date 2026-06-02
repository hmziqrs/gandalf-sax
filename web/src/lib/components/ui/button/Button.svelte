<script lang="ts">
	import { cn } from "$lib/utils";
	import { buttonVariants, type ButtonProps } from "./index.js";

	let {
		variant = "default",
		size = "default",
		class: className,
		children,
		...restProps
	}: ButtonProps = $props();
</script>

<button
	class={cn(buttonVariants({ variant, size }), className)}
	{...restProps}
>
	{@render children?.()}
</button>
