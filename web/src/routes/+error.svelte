<script lang="ts">
	import { page } from "$app/state";
	import { Button } from "$lib/components/ui/button";
	import Header from "$lib/components/Header.svelte";
	import Footer from "$lib/components/Footer.svelte";
	import Seo from "$lib/components/Seo.svelte";
	import { pages } from "$lib/seo";
	import { Home, Play } from "@lucide/svelte";

	const status = $derived(page.status);
	const message = $derived(
		status === 404
			? "This page has vanished like Gandalf's hat."
			: page.error?.message ?? "Something went wrong."
	);
</script>

<Seo seo={pages["404"]} />

<svelte:head>
	<meta name="robots" content="noindex, follow" />
</svelte:head>

<div class="flex h-screen flex-col bg-background text-foreground">
	<Header />
	<main class="flex flex-1 flex-col items-center justify-center px-4 text-center">
		<p class="text-7xl font-bold text-primary">{status}</p>
		<h1 class="mt-4 text-2xl font-bold md:text-3xl">
			{status === 404 ? "Page Not Found" : "Error"}
		</h1>
		<p class="mt-2 max-w-md text-muted-foreground">{message}</p>
		<div class="mt-8 flex flex-col items-center gap-3 sm:flex-row">
			<Button href="/" class="gap-2">
				<Home size={18} />
				Go Home
			</Button>
			<Button variant="outline" href="/" class="gap-2">
				<Play size={18} />
				Watch Gandalf
			</Button>
		</div>
	</main>
	<Footer />
</div>
