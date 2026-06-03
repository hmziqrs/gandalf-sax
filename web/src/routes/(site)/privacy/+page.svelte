<script>
	import Seo from "$lib/components/Seo.svelte";
	import { pages } from "$lib/seo";
</script>

<Seo seo={pages['/privacy']} />

<div class="mx-auto max-w-3xl px-4 py-12">
	<h1 class="text-3xl font-bold md:text-4xl">Privacy Policy</h1>
	<p class="mt-2 text-sm text-muted-foreground">Last updated: June 3, 2026</p>

	<div class="mt-6 space-y-6 leading-relaxed text-muted-foreground">
		<section>
			<h2 class="text-lg font-semibold text-foreground">Information We Collect</h2>
			<p class="mt-2">
				Epic Sax Gandalf is a simple entertainment application. We do not
				collect, store, or transmit any personal information. The app does not
				require an account, does not use cookies for tracking, and does not
				gather analytics.
			</p>
		</section>

		<section>
			<h2 class="text-lg font-semibold text-foreground">Local Storage</h2>
			<p class="mt-2">
				The application stores your theme preference (light, dark, or system)
				locally in your browser's localStorage. This data never leaves your
				device and is used solely to remember your visual preference between
				sessions.
			</p>
		</section>

		<section>
			<h2 class="text-lg font-semibold text-foreground">NTP Synchronization</h2>
			<p class="mt-2">
				To synchronize the video playback across all viewers, the app connects
				to public Network Time Protocol (NTP) servers. This connection is used
				only to determine the current time with high precision. No personal data
				is sent to these servers.
			</p>
		</section>

		<section>
			<h2 class="text-lg font-semibold text-foreground">Third-Party Services</h2>
			<p class="mt-2">
				The app links to external content (such as the original video on
				YouTube). These external services have their own privacy policies, which
				we encourage you to review. We are not responsible for the privacy
				practices of third-party sites.
			</p>
		</section>

		<section>
			<h2 class="text-lg font-semibold text-foreground">Your Rights</h2>
			<p class="mt-2">
				Since we do not collect any personal data, there is no data to access,
				modify, or delete. You can clear your theme preference at any time by
				clearing your browser's localStorage.
			</p>
		</section>

		<section>
			<h2 class="text-lg font-semibold text-foreground">Contact</h2>
			<p class="mt-2">
				If you have questions about this privacy policy, reach out via the
				<a
					href="/contact"
					class="font-medium text-primary transition-colors hover:text-primary/80"
				>
					contact page
				</a>.
			</p>
		</section>
	</div>
</div>
