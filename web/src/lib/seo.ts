export const SITE = {
	name: 'Epic Sax Gandalf',
	tagline: 'Billions must be entertained!',
	url: 'https://sax.hmziq.rs',
	creator: 'hmziqrs',
	twitter: '@hmziqrs',
	ogImage: '/og-image.png',
} as const;

export interface PageSeo {
	title: string;
	description: string;
	path: string;
	type?: 'website' | 'article';
	image?: string;
	jsonLd?: Record<string, unknown>;
}

export const pages: Record<string, PageSeo> = {
	'/': {
		title: 'Epic Sax Gandalf',
		description: 'Behold the glory of infinite Gandalf! Watch Gandalf play the saxophone in an endless, NTP-synced loop. Billions must be entertained!',
		path: '/',
	},
	'/home': {
		title: 'Epic Sax Gandalf — Billions Must Be Entertained',
		description: 'Watch Gandalf play the saxophone forever, perfectly synchronized across the world. An infinite, NTP-synced entertainment experience.',
		path: '/home',
	},
	'/about': {
		title: 'About — Epic Sax Gandalf',
		description: 'Learn about Epic Sax Gandalf — the synchronized, infinite saxophone experience built with SvelteKit and NTP time sync.',
		path: '/about',
	},
	'/contact': {
		title: 'Contact — Epic Sax Gandalf',
		description: 'Get in touch with the creator of Epic Sax Gandalf. Find links to website, GitHub, and X (Twitter).',
		path: '/contact',
	},
	'/privacy': {
		title: 'Privacy Policy — Epic Sax Gandalf',
		description: 'Privacy policy for Epic Sax Gandalf. We collect no personal data, use no cookies, and store only your theme preference locally.',
		path: '/privacy',
	},
	'/terms': {
		title: 'Terms of Service — Epic Sax Gandalf',
		description: 'Terms of service for Epic Sax Gandalf — a free, open-source entertainment application.',
		path: '/terms',
	},
};
