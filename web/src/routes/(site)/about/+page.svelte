<script>
	import Seo from "$lib/components/Seo.svelte";
	import { pages } from "$lib/seo";
</script>

<Seo seo={pages['/about']} />

<div class="mx-auto max-w-3xl px-4 py-12">
	<h1 class="text-3xl font-bold md:text-4xl">About Epic Sax Gandalf</h1>

	<div class="mt-6 space-y-4 leading-relaxed text-muted-foreground">
		<p>
			Epic Sax Gandalf is a celebration of one of the internet's most beloved
			memes — Gandalf the Grey, slaying on the saxophone. This project takes
			that iconic moment and turns it into an infinite, synchronized experience.
		</p>

		<p>
			Every viewer around the world sees the same frame at the same time. Using
			Network Time Protocol (NTP) synchronization, the video loops seamlessly so
			that billions can be entertained in perfect harmony.
		</p>

		<h2 class="pt-4 text-xl font-semibold text-foreground">The Technology</h2>
		<p>
			Built as a cross-platform experience, Epic Sax Gandalf uses modern web
			technologies (SvelteKit, Svelte 5) for the web, and native Swift/SwiftUI
			for Apple platforms. The NTP client ensures frame-accurate synchronization
			across all devices, regardless of location.
		</p>

		<h2 class="pt-4 text-xl font-semibold text-foreground">The Original</h2>
		<p>
			The video that started it all. Credit goes to the original creator — you can
			watch the source video on
			<a
				href="https://youtu.be/BBGEG21CGo0"
				target="_blank"
				rel="noopener noreferrer"
				class="font-medium text-primary transition-colors hover:text-primary/80"
			>
				YouTube
			</a>.
		</p>

		<h2 class="pt-4 text-xl font-semibold text-foreground">Open Source</h2>
		<p>
			This project is open source and available on
			<a
				href="https://github.com/hmziqrs/gandalf-sax"
				target="_blank"
				rel="noopener noreferrer"
				class="font-medium text-primary transition-colors hover:text-primary/80"
			>
				GitHub
			</a>.
			Contributions, bug reports, and feature requests are welcome.
		</p>
	</div>
</div>
