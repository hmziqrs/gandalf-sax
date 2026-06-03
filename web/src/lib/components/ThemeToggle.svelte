<script lang="ts">
	import { getThemeMode, setThemeMode } from "$lib/stores.svelte";
	import type { ThemeMode } from "$lib/stores.svelte";
	import { Sun, Moon, Monitor } from "@lucide/svelte";
	import { Button } from "$lib/components/ui/button";

	function cycleTheme() {
		const mode = getThemeMode();
		const next: ThemeMode = mode === "light" ? "dark" : mode === "dark" ? "system" : "light";
		setThemeMode(next);
	}

	let current = $derived(getThemeMode());
</script>

<Button variant="ghost" size="icon" onclick={cycleTheme} aria-label="Toggle theme">
	{#if current === "light"}
		<Sun size={18} />
	{:else if current === "dark"}
		<Moon size={18} />
	{:else}
		<Monitor size={18} />
	{/if}
</Button>
