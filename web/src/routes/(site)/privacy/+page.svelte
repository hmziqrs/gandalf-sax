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
				require an account, does not use cookies for tracking, does not
				gather analytics, and does not use any form of user profiling.
			</p>
		</section>

		<section>
			<h2 class="text-lg font-semibold text-foreground">Local Storage</h2>
			<p class="mt-2">
				The application stores your theme preference (light, dark, or system)
				locally in your browser's <strong class="text-foreground">localStorage</strong>
				under the key <code class="rounded bg-muted px-1.5 py-0.5 text-sm text-foreground">gandalf_theme</code>.
				This is the only data stored on your device. It never leaves your browser,
				is never transmitted to any server, and is used solely to remember your
				visual preference between sessions.
			</p>
			<p class="mt-2">
				You can remove this data at any time by opening your browser's developer
				tools and deleting the entry, or by clearing your browser's site data.
				The app will simply default to your system's color scheme.
			</p>
		</section>

		<section>
			<h2 class="text-lg font-semibold text-foreground">NTP Synchronization</h2>
			<p class="mt-2">
				To synchronize the video playback across all viewers, the app connects
				to public Network Time Protocol (NTP) servers. This connection is used
				only to determine the current time with high precision. These servers never
				receive personal data — they only respond with timestamps.
			</p>
		</section>

		<section>
			<h2 class="text-lg font-semibold text-foreground">Third-Party Services</h2>
			<p class="mt-2">
				The app links to external content (such as the original video on
				YouTube). These external services have their own privacy policies, which
				we encourage you to review. We don't control how third-party
				sites handle privacy.
			</p>
		</section>

		<section>
			<h2 class="text-lg font-semibold text-foreground">GDPR Compliance (EU)</h2>
			<p class="mt-2">
				This site is accessible worldwide, including to visitors from the
				European Economic Area (EEA). Under the General Data Protection Regulation
				(GDPR), we confirm that:
			</p>
			<ul class="mt-2 list-inside list-disc space-y-1">
				<li>We do not act as a data controller or data processor for any personal data.</li>
				<li>No personal data is collected, processed, or transferred.</li>
				<li>No cookies or tracking technologies are deployed.</li>
				<li>The only local storage used (<code class="rounded bg-muted px-1.5 py-0.5 text-sm text-foreground">gandalf_theme</code>) is strictly
					necessary for the site's functionality and does not require consent under
					GDPR Article 6(1)(b) — it is essential to the service you requested.</li>
			</ul>
			<p class="mt-2">
				Since no personal data is held, there is no data to access, rectify,
				erase, or port. If you believe otherwise, please reach out via the
				<a
					href="/contact"
					class="font-medium text-primary transition-colors hover:text-primary/80"
				>
					contact page
				</a>.
			</p>
		</section>

		<section>
			<h2 class="text-lg font-semibold text-foreground">CCPA Compliance (California)</h2>
			<p class="mt-2">
				Under the California Consumer Privacy Act (CCPA), California residents
				have the right to know what personal information is collected. Here's the
				full disclosure: we collect <strong class="text-foreground">none</strong>.
				No personal information is sold, shared, or used for advertising.
			</p>
			<p class="mt-2">
				There are no "Do Not Sell" obligations because nothing is sold.
				There is no data to delete upon request because nothing is stored.
				California residents enjoy the same experience as everyone else:
				an unhinged sax-playing wizard and zero data collection.
			</p>
		</section>

		<section>
			<h2 class="text-lg font-semibold text-foreground">Your Rights</h2>
			<p class="mt-2">
				Since we do not collect any personal data, there is no data to access,
				modify, or delete. You can clear your theme preference at any time by
				clearing your browser's localStorage. No matter where you are in the
				world, your rights are fully respected — mostly because there's nothing
				to violate.
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
