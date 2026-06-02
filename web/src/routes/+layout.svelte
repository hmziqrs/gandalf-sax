<script lang="ts">
	import "../app.css";
	import { themeMode } from "$lib/stores";
	import type { ThemeMode } from "$lib/stores";

	let { children } = $props();

	function applyTheme(mode: ThemeMode) {
		if (typeof document === "undefined") return;
		const root = document.documentElement;
		let resolved = mode;
		if (mode === "system") {
			resolved = window.matchMedia("(prefers-color-scheme: dark)").matches
				? "dark"
				: "light";
		}
		root.classList.toggle("dark", resolved === "dark");
	}

	$effect(() => {
		applyTheme($themeMode);

		if (typeof window !== "undefined") {
			const mq = window.matchMedia("(prefers-color-scheme: dark)");
			const handler = () => {
				if ($themeMode === "system") applyTheme("system");
			};
			mq.addEventListener("change", handler);
			return () => mq.removeEventListener("change", handler);
		}
	});
</script>

<div class="min-h-screen bg-background text-foreground">
	{@render children()}
</div>
