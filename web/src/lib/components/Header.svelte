<script lang="ts">
	import { Button } from "$lib/components/ui/button";
	import ThemeToggle from "./ThemeToggle.svelte";
	import { Menu, X, Music } from "@lucide/svelte";
	import { page } from "$app/state";

	const navItems = [
		{ href: "/home", label: "Home" },
		{ href: "/about", label: "About" },
		{ href: "/contact", label: "Contact" },
	];

	let mobileMenuOpen = $state(false);

	function isActive(href: string): boolean {
		return page.url.pathname === href;
	}
</script>

<header
	class="sticky top-0 z-50 w-full border-b border-border/40 bg-background/80 backdrop-blur-lg"
>
	<div class="container mx-auto flex h-14 items-center justify-between px-4">
		<!-- Brand -->
		<a href="/home" class="flex items-center gap-2 text-lg font-bold">
			<Music size={20} class="text-primary" />
			<span>Epic Sax Gandalf</span>
		</a>

		<!-- Desktop nav -->
		<nav class="hidden items-center gap-6 md:flex">
			{#each navItems as item}
				<a
					href={item.href}
					class="text-sm font-medium transition-colors {isActive(item.href)
						? 'text-foreground'
						: 'text-muted-foreground hover:text-foreground'}"
				>
					{item.label}
				</a>
			{/each}
		</nav>

		<!-- Right side -->
		<div class="flex items-center gap-2">
			<ThemeToggle />
			<Button
				variant="ghost"
				size="icon"
				class="md:hidden"
				onclick={() => (mobileMenuOpen = !mobileMenuOpen)}
				aria-label={mobileMenuOpen ? "Close menu" : "Open menu"}
			>
				{#if mobileMenuOpen}
					<X size={20} />
				{:else}
					<Menu size={20} />
				{/if}
			</Button>
		</div>
	</div>

	<!-- Mobile nav dropdown -->
	{#if mobileMenuOpen}
		<div class="border-t border-border/40 bg-background px-4 py-3 md:hidden">
			<nav class="flex flex-col gap-3">
				{#each navItems as item}
					<a
						href={item.href}
						class="text-sm font-medium transition-colors {isActive(item.href)
							? 'text-foreground'
							: 'text-muted-foreground hover:text-foreground'}"
						onclick={() => (mobileMenuOpen = false)}
					>
						{item.label}
					</a>
				{/each}
			</nav>
		</div>
	{/if}
</header>
