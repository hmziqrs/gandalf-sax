<script>
	import Seo from "$lib/components/Seo.svelte";
	import PageHeader from "$lib/components/PageHeader.svelte";
	import { pages } from "$lib/seo";
</script>

<Seo seo={pages['/privacy']} />

<PageHeader
	eyebrow="Legal"
	title="Privacy Policy"
	meta="Last updated: June 4, 2026"
/>

<div class="mx-auto max-w-3xl px-4 py-14">
	<div class="space-y-10 leading-relaxed text-muted-foreground">
		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">01</span>
				Information We Collect
			</h2>
			<p class="mt-3">
				Epic Sax Gandalf is a simple entertainment site. We do not ask for an
				account, a name, an email address, or any other personal identifier. The
				only information processed is anonymous, aggregate usage data collected
				through analytics (see below) and a single theme preference stored in
				your browser. We do not sell data and we show no ads.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">02</span>
				Analytics
			</h2>
			<p class="mt-3">
				We use <strong class="text-foreground">Firebase Analytics</strong>
				(Google Analytics) to understand how the site is used — for example,
				which features are opened, playback and sync behavior, and rough,
				IP-derived geography (country/region level). This helps us improve the
				experience. The data is aggregated and is not used to identify you
				personally.
			</p>
			<p class="mt-2">
				Google Analytics sets cookies and a randomly generated client identifier
				to distinguish browsers and measure repeat usage. We do not link this to
				any personal information because we don't collect any. Google processes
				this data as described in
				<a
					href="https://policies.google.com/privacy"
					target="_blank"
					rel="noopener noreferrer"
					class="font-medium text-primary transition-colors hover:text-primary/80"
				>Google's Privacy Policy</a>.
			</p>
			<p class="mt-2">
				You can opt out by using a browser that blocks analytics, an ad/tracker
				blocker, enabling "Do Not Track," or installing the
				<a
					href="https://tools.google.com/dlpage/gaoptout"
					target="_blank"
					rel="noopener noreferrer"
					class="font-medium text-primary transition-colors hover:text-primary/80"
				>Google Analytics Opt-out Browser Add-on</a>. The site works fully
				with analytics blocked.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">03</span>
				Local Storage
			</h2>
			<p class="mt-3">
				The site stores your theme preference (light, dark, or system) locally
				in your browser's <strong class="text-foreground">localStorage</strong>
				under the key <code class="rounded bg-muted px-1.5 py-0.5 text-sm text-foreground">gandalf_theme</code>,
				along with a flag recording that you dismissed the storage notice. This
				data never leaves your browser and is used solely to remember your
				preferences between sessions.
			</p>
			<p class="mt-2">
				You can remove it at any time by clearing your browser's site data. The
				site will simply default to your system's color scheme.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">04</span>
				NTP Synchronization
			</h2>
			<p class="mt-3">
				To synchronize the video playback across all viewers, the site connects
				to a public time API. This connection is used only to determine the
				current time with high precision. It receives no personal data — only a
				timestamp is returned.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">05</span>
				Third-Party Services
			</h2>
			<p class="mt-3">
				We rely on a few third-party services: Google Firebase/Analytics
				(usage measurement), a public time API (clock sync), and links to
				external content such as the original video on YouTube. Each has its own
				privacy policy, which we encourage you to review. We don't control how
				third-party sites handle your data once you leave.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">06</span>
				GDPR Compliance (EU)
			</h2>
			<p class="mt-3">
				This site is accessible worldwide, including to visitors from the
				European Economic Area (EEA). Under the General Data Protection
				Regulation (GDPR):
			</p>
			<ul class="mt-3 list-inside list-disc space-y-1">
				<li>We collect no directly identifying personal data (no name, email, or account).</li>
				<li>Analytics processes anonymous usage data and online identifiers (e.g. cookie/client IDs and IP-derived location) via Google Analytics.</li>
				<li>The lawful basis for analytics is our legitimate interest in understanding and improving the service; you can opt out at any time (see the Analytics section).</li>
				<li>The <code class="rounded bg-muted px-1.5 py-0.5 text-sm text-foreground">gandalf_theme</code> local storage entry is strictly necessary for functionality and does not require consent under GDPR Article 6(1)(b).</li>
			</ul>
			<p class="mt-2">
				To exercise any data rights regarding analytics data, you can use the
				opt-out methods above or contact Google as the analytics processor. If
				you have questions, reach out via the
				<a
					href="/contact"
					class="font-medium text-primary transition-colors hover:text-primary/80"
				>contact page</a>.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">07</span>
				CCPA Compliance (California)
			</h2>
			<p class="mt-3">
				Under the California Consumer Privacy Act (CCPA), California residents
				have the right to know what personal information is collected. We
				collect no directly identifying personal information. Analytics gathers
				anonymous usage data and online identifiers as described above.
			</p>
			<p class="mt-2">
				We do not sell or share your personal information for money or
				cross-context behavioral advertising. There are no ads on this site. You
				can opt out of analytics at any time using the methods in the Analytics
				section.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">08</span>
				Your Rights
			</h2>
			<p class="mt-3">
				Because we hold no account or directly identifying data, there is no
				profile to access, correct, or delete on our side. You can clear your
				local theme preference by clearing your browser's site data, and you can
				opt out of analytics at any time. Wherever you are in the world, these
				choices are fully respected.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">09</span>
				Contact
			</h2>
			<p class="mt-3">
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
