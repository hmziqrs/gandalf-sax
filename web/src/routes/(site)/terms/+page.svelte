<script>
	import Seo from "$lib/components/Seo.svelte";
	import PageHeader from "$lib/components/PageHeader.svelte";
	import { pages } from "$lib/seo";
	import { logClickOriginalVideo } from "$lib/analytics";
</script>

<Seo seo={pages['/terms']} />

<PageHeader
	eyebrow="Legal"
	title="Terms of Service"
	meta="Last updated: June 3, 2026"
/>

<div class="mx-auto max-w-3xl px-4 py-14">
	<div class="space-y-10 leading-relaxed text-muted-foreground">
		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">01</span>
				Acceptance
			</h2>
			<p class="mt-3">
				By accessing and using Epic Sax Gandalf, you agree to be bound by these
				Terms of Service. If you do not agree with any part of these terms, you
				should not use the application.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">02</span>
				Use of Service
			</h2>
			<p class="mt-3">
				Epic Sax Gandalf is a free entertainment application provided as-is. You
				may use it for personal, non-commercial entertainment purposes. The
				service is provided without any guarantees of availability, reliability,
				or fitness for a particular purpose.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">03</span>
				Intellectual Property
			</h2>
			<p class="mt-3">
				The application code is open source under the terms of its repository
				license. The video content features a meme based on the character Gandalf
				from "The Lord of the Rings." The original video is credited to its
				respective creator and is available on
				<a
					href="https://youtu.be/BBGEG21CGo0?ref=gandalf.hmziq.xyz"
					target="_blank"
					rel="noopener noreferrer"
					onclick={() => logClickOriginalVideo("terms")}
					class="font-medium text-primary transition-colors hover:text-primary/80"
				>
					YouTube
				</a>.
				All rights to the original content belong to their respective owners.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">04</span>
				Limitation of Liability
			</h2>
			<p class="mt-3">
				The application is provided "as is" without warranty of any kind. In no
				event shall the developer be liable for any damages arising from the use
				of this application. Use at your own risk.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">05</span>
				Governing Law
			</h2>
			<p class="mt-3">
				These terms are governed by and construed in accordance with applicable
				federal and state laws, without regard to conflict of law provisions.
				Any disputes arising from the use of this application shall be resolved
				in the applicable courts.
			</p>
			<p class="mt-2">
				If you are accessing this service from outside the United States, you
				are responsible for compliance with any applicable local laws. This
				site is made available globally, but these terms are rooted in U.S. law.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">06</span>
				Changes to Terms
			</h2>
			<p class="mt-3">
				We reserve the right to modify these terms at any time. Changes will be
				reflected on this page with an updated "Last updated" date. Continued use
				of the application after changes constitutes acceptance of the new terms.
			</p>
		</section>

		<section>
			<h2 class="flex items-center gap-3 text-lg font-semibold text-foreground">
				<span class="font-mono text-sm text-primary">07</span>
				Contact
			</h2>
			<p class="mt-3">
				For questions about these terms, reach out via the
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
