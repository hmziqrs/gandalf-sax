<script>
	import Seo from "$lib/components/Seo.svelte";
	import { pages } from "$lib/seo";
	import { Button } from "$lib/components/ui/button";

	const faqs = [
		{
			question: "What is Epic Sax Gandalf?",
			answer:
				"Epic Sax Gandalf is an infinite, NTP-synchronized loop of the iconic Gandalf saxophone meme from The Lord of the Rings. Every viewer around the world sees the same frame at the exact same time. Think of it as a globally shared moment of pure, unfiltered sax.",
		},
		{
			question: "What is the Gandalf saxophone meme origin?",
			answer:
				"The meme originated from a YouTube video that set footage of Gandalf from The Lord of the Rings to a saxophone soundtrack. It became one of the internet's most beloved and shared memes. You can still watch the original on YouTube.",
		},
		{
			question: "How does NTP synchronization work?",
			answer:
				"NTP (Network Time Protocol) connects to public time servers to determine the exact current time with millisecond precision. The video player uses this to sync playback so every viewer sees the same frame simultaneously, regardless of where they are. Yes, someone in Tokyo and someone in Buenos Aires are vibing to the exact same frame.",
		},
		{
			question: "Is Epic Sax Gandalf open source?",
			answer:
				"Yes! The project is fully open source and available on GitHub. Contributions, bug reports, and feature requests are welcome. Come help make the sax even more epic.",
		},
		{
			question: "Who created the original sax guy meme?",
			answer:
				"The original video was created by an anonymous internet artist and uploaded to YouTube. Epic Sax Gandalf is a tribute to that legendary creation, adding infinite looping and global NTP synchronization to take it to the next level.",
		},
		{
			question: "What platforms is Epic Sax Gandalf available on?",
			answer:
				"Epic Sax Gandalf is available on the web, macOS, and iOS. The web version is built with SvelteKit, while the Apple apps use native Swift and SwiftUI. Entertain yourself on any device.",
		},
		{
			question: "Does Epic Sax Gandalf collect any personal data?",
			answer:
				"No. The app collects no personal data, uses no tracking cookies, and requires no account. It only stores your theme preference (light/dark) locally in your browser. That's it. No catches, no fine print.",
		},
	];
</script>

<Seo seo={pages['/faq']} />

<div class="mx-auto max-w-3xl px-4 py-12">
	<h1 class="text-3xl font-bold md:text-4xl">Frequently Asked Questions</h1>
	<p class="mt-2 text-muted-foreground">
		Everything you wanted to know about Epic Sax Gandalf (and maybe a few things you didn't).
	</p>

	<div class="mt-8 divide-y divide-border">
		{#each faqs as faq}
			<div class="py-6">
				<h2 class="text-lg font-semibold text-foreground">{faq.question}</h2>
				<p class="mt-2 leading-relaxed text-muted-foreground">{faq.answer}</p>
			</div>
		{/each}
	</div>

	<div class="mt-10 flex flex-col gap-3 sm:flex-row">
		<a href="/play">
			<Button>Watch the Video</Button>
		</a>
		<a href="/about">
			<Button variant="outline">Learn More</Button>
		</a>
	</div>
</div>
