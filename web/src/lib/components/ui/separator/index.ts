import { cn } from "$lib/utils";
import type { Snippet } from "svelte";
import type { HTMLAttributes } from "svelte/elements";

type SeparatorProps = HTMLAttributes<HTMLDivElement> & {
	orientation?: "horizontal" | "vertical";
	decorative?: boolean;
	children?: Snippet;
	class?: string;
};

export { type SeparatorProps };
export { default as Separator } from "./Separator.svelte";
