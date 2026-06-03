<script lang="ts">
	import Header from "$lib/components/Header.svelte";
	import Footer from "$lib/components/Footer.svelte";

	let { children } = $props();
</script>

<div class="flex h-screen flex-col overflow-y-auto bg-background text-foreground">
	<Header />
	<main class="flex-1">
		{@render children()}
	</main>
	<Footer />
</div>
