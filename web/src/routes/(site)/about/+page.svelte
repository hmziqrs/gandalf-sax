<script>
	import Seo from "$lib/components/Seo.svelte";
	import PageHeader from "$lib/components/PageHeader.svelte";
	import { pages } from "$lib/seo";
	import { Button } from "$lib/components/ui/button";
	import { logClickOriginalVideo, logClickExternalLink } from "$lib/analytics";
</script>

<Seo seo={pages['/about']} />

<PageHeader
	eyebrow="About"
	title="About Epic Sax Gandalf"
	lead="A wonderfully stupid internet meme, given the most over-engineered, frame-accurate treatment possible."
/>

<article class="mx-auto max-w-3xl px-4 py-14">
	<div class="space-y-4 leading-relaxed text-muted-foreground">
		<p>
			Epic Sax Gandalf is a celebration of one of the internet's most beloved
			memes — the epic sax guy meme, remixed with Gandalf the Grey slaying on
			the saxophone. This is an infinite, synchronized version of the
			Gandalf sax meme, and
			<a href="/" class="font-medium text-primary transition-colors hover:text-primary/80">you can watch it right now</a>.
		</p>
		<p>
			Every viewer around the world sees the same frame at the same time. Using
			Network Time Protocol (NTP) synchronization, the video loops seamlessly so
			that billions can be entertained in perfect harmony.
		</p>
	</div>

	<div class="mt-12 space-y-12">
		<section class="border-l-2 border-primary/30 pl-6">
			<h2 class="font-mono text-sm font-semibold uppercase tracking-wider text-foreground">
				The Original Eurovision Sax Meme
			</h2>
			<div class="mt-3 space-y-4 leading-relaxed text-muted-foreground">
				<p>
					The roots of this meme trace back to the
					<a
						href="https://en.wikipedia.org/wiki/Eurovision_Song_Contest_2010"
						target="_blank"
						rel="noopener noreferrer"
						onclick={() => logClickExternalLink("https://en.wikipedia.org/wiki/Eurovision_Song_Contest_2010", "eurovision_wiki")}
						class="font-medium text-primary transition-colors hover:text-primary/80"
					>Eurovision Song Contest 2010</a>,
					where Moldova's SunStroke Project performed "Run Away" featuring
					epic saxophonist Sergey Stepanov. His impassioned saxophone solo,
					choreographed with dramatic head movements and laser-sharp intensity,
					instantly captured the internet's imagination. Within days, clips of the
					performance flooded forums and social media, and the "Epic Sax Guy" meme
					was born.
				</p>
				<p>
					The internet did what the internet does — it mashed him into everything.
					One of the most enduring remixes placed Gandalf (yes, the wizard from
					Lord of the Rings) in Stepanov's place, grinding out that riff on a
					saxophone instead of fighting Balrogs. The absurdity of a wise Maia
					dropping bars on a brass instrument proved too perfect to ignore, and
					the Gandalf sax meme was born. That remix is the
					<a
						href="https://youtu.be/BBGEG21CGo0"
						target="_blank"
						rel="noopener noreferrer"
						onclick={() => logClickOriginalVideo("about")}
						class="font-medium text-primary transition-colors hover:text-primary/80"
					>video that started it all</a>.
				</p>
			</div>
		</section>

		<section class="border-l-2 border-primary/30 pl-6">
			<h2 class="font-mono text-sm font-semibold uppercase tracking-wider text-foreground">
				Why This Exists
			</h2>
			<div class="mt-3 space-y-4 leading-relaxed text-muted-foreground">
				<p>
					Some memes fade. The sax guy meme refuses to. This project was built
					because the idea of a globally synchronized, never-ending sax loop was
					too good to stay as a quick YouTube video. What if everyone pressing play
					at the same moment actually saw the same frame — no matter where they
					were?
				</p>
				<p>
					That question turned into a weekend experiment, then a side project, then
					a cross-platform app. The goal was never to go viral or build a startup.
					It was to take something wonderfully stupid on the internet and give it
					the most over-engineered, technically precise treatment possible. NTP
					sync, frame-accurate playback, native apps — all for a sax meme. That
					contrast is the whole point.
				</p>
			</div>
		</section>

		<section class="border-l-2 border-primary/30 pl-6">
			<h2 class="font-mono text-sm font-semibold uppercase tracking-wider text-foreground">
				The Technology
			</h2>
			<div class="mt-3 space-y-4 leading-relaxed text-muted-foreground">
				<p>
					Built as a cross-platform experience, Epic Sax Gandalf uses modern web
					technologies (SvelteKit, Svelte 5) for the web, and native Swift/SwiftUI
					for Apple platforms. The NTP client ensures frame-accurate synchronization
					across all devices, regardless of location.
				</p>
			</div>
		</section>

		<section class="border-l-2 border-primary/30 pl-6">
			<h2 class="font-mono text-sm font-semibold uppercase tracking-wider text-foreground">
				Open Source
			</h2>
			<div class="mt-3 space-y-4 leading-relaxed text-muted-foreground">
				<p>
					This project is open source and available on
					<a
						href="https://github.com/hmziqrs/gandalf-sax"
						target="_blank"
						rel="noopener noreferrer"
						onclick={() => logClickExternalLink("https://github.com/hmziqrs/gandalf-sax", "github_repo")}
						class="font-medium text-primary transition-colors hover:text-primary/80"
					>
						GitHub
					</a>.
					Contributions, bug reports, and feature requests are welcome. If you have
					ideas or just want to say hi,
					<a href="/contact" class="font-medium text-primary transition-colors hover:text-primary/80">get in touch</a>.
				</p>
			</div>
		</section>
	</div>

	<div class="mt-14 flex flex-col gap-3 border-t border-border pt-8 sm:flex-row">
		<a href="/">
			<Button>Watch the Video</Button>
		</a>
		<a href="/contact">
			<Button variant="outline">Get in Touch</Button>
		</a>
	</div>
</article>
