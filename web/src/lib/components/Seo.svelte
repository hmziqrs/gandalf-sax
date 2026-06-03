<script lang="ts">
	import { SITE, type PageSeo } from '$lib/seo';

	let { seo }: { seo: PageSeo } = $props();

	const canonical = $derived(`${SITE.url}${seo.path}`);
	const image = $derived(seo.image ?? SITE.ogImage);
	const type = $derived(seo.type ?? 'website');
</script>

<svelte:head>
	<title>{seo.title}</title>
	<meta name="description" content={seo.description} />
	<link rel="canonical" href={canonical} />

	<!-- Open Graph -->
	<meta property="og:type" content={type} />
	<meta property="og:url" content={canonical} />
	<meta property="og:title" content={seo.title} />
	<meta property="og:description" content={seo.description} />
	<meta property="og:image" content={`${SITE.url}${image}`} />
	<meta property="og:site_name" content={SITE.name} />

	<!-- Twitter Card -->
	<meta name="twitter:card" content="summary" />
	<meta name="twitter:title" content={seo.title} />
	<meta name="twitter:description" content={seo.description} />
	<meta name="twitter:image" content={`${SITE.url}${image}`} />
	<meta name="twitter:site" content={SITE.twitter} />
	<meta name="twitter:creator" content={SITE.twitter} />

	<!-- JSON-LD Structured Data -->
	{@html `<script type="application/ld+json">${JSON.stringify(seo.jsonLd ?? {
		'@context': 'https://schema.org',
		'@type': 'WebPage',
		name: seo.title,
		description: seo.description,
		url: canonical,
		isPartOf: {
			'@type': 'WebSite',
			name: SITE.name,
			url: SITE.url,
		},
	})}</script>`}
</svelte:head>
