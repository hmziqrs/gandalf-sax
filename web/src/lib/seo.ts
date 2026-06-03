export const SITE = {
	name: 'Epic Sax Gandalf',
	tagline: 'Billions must be entertained!',
	url: 'https://gandalf.hmziq.xyz',
	creator: 'hmziqrs',
	twitter: '@hmziqrs',
	ogImage: '/og-image.png',
	ogImageWidth: 1200,
	ogImageHeight: 630,
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
		title: 'Epic Sax Gandalf — The Infinite Gandalf Sax Meme, NTP-Synced',
		description: 'Watch the Epic Sax Guy meme remixed with Gandalf from Lord of the Rings. An infinite, NTP-synced saxophone loop born from the Eurovision sax meme. Billions must be entertained!',
		path: '/',
		jsonLd: {
			'@context': 'https://schema.org',
			'@type': 'VideoObject',
			name: 'Epic Sax Gandalf — Infinite Loop',
			description: 'Watch Gandalf play the saxophone in an endless, NTP-synced loop.',
			contentUrl: SITE.url,
		},
	},
	'/home': {
		title: 'Epic Sax Gandalf — Billions Must Be Entertained',
		description: 'Watch Gandalf play the saxophone forever, perfectly synchronized across the world. An infinite, NTP-synced entertainment experience.',
		path: '/home',
		jsonLd: {
			'@context': 'https://schema.org',
			'@type': 'WebSite',
			name: SITE.name,
			url: SITE.url,
			description: 'Watch the Epic Sax Guy meme remixed with Gandalf from Lord of the Rings. An infinite, NTP-synced saxophone loop. Billions must be entertained!',
		},
	},
	'/about': {
		title: 'About Epic Sax Gandalf — The Gandalf Sax Meme Story',
		description: 'The story behind the epic sax guy meme, the Eurovision sax meme origins, and how the Gandalf sax meme from Lord of the Rings became an infinite NTP-synced experience.',
		path: '/about',
		jsonLd: {
			'@context': 'https://schema.org',
			'@type': 'SoftwareApplication',
			name: SITE.name,
			description: 'An infinite, NTP-synced saxophone experience. Watch Gandalf play the saxophone in perfect synchronization across the world.',
			applicationCategory: 'Entertainment',
			operatingSystem: 'Web, iOS, macOS',
			url: SITE.url,
			offers: {
				'@type': 'Offer',
				price: '0',
				priceCurrency: 'USD',
			},
		},
	},
	'/faq': {
		title: 'FAQ — Epic Sax Gandalf',
		description: 'Frequently asked questions about Epic Sax Gandalf. What is it, how does NTP sync work, who created the sax guy meme, and more.',
		path: '/faq',
		jsonLd: {
			'@context': 'https://schema.org',
			'@type': 'FAQPage',
			mainEntity: [
				{
					'@type': 'Question',
					name: 'What is Epic Sax Gandalf?',
					acceptedAnswer: {
						'@type': 'Answer',
						text: 'Epic Sax Gandalf is an infinite, NTP-synchronized loop of the iconic Gandalf saxophone meme from The Lord of the Rings. Every viewer around the world sees the same frame at the exact same time.',
					},
				},
				{
					'@type': 'Question',
					name: 'What is the Gandalf saxophone meme origin?',
					acceptedAnswer: {
						'@type': 'Answer',
						text: "The meme originated from a YouTube video that set footage of Gandalf from The Lord of the Rings to a saxophone soundtrack. It became one of the internet's most beloved and shared memes.",
					},
				},
				{
					'@type': 'Question',
					name: 'How does NTP synchronization work?',
					acceptedAnswer: {
						'@type': 'Answer',
						text: 'NTP (Network Time Protocol) connects to public time servers to determine the exact current time with millisecond precision. The video player uses this to sync playback so every viewer sees the same frame simultaneously, regardless of their location.',
					},
				},
				{
					'@type': 'Question',
					name: 'Is Epic Sax Gandalf open source?',
					acceptedAnswer: {
						'@type': 'Answer',
						text: 'Yes! The project is fully open source and available on GitHub. Contributions, bug reports, and feature requests are welcome.',
					},
				},
				{
					'@type': 'Question',
					name: 'Who created the original sax guy meme?',
					acceptedAnswer: {
						'@type': 'Answer',
						text: 'The original video was created by an anonymous internet artist and uploaded to YouTube. Epic Sax Gandalf is a tribute to that legendary creation, adding infinite looping and global NTP synchronization.',
					},
				},
				{
					'@type': 'Question',
					name: 'What platforms is Epic Sax Gandalf available on?',
					acceptedAnswer: {
						'@type': 'Answer',
						text: 'Epic Sax Gandalf is available on the web, macOS, and iOS. The web version is built with SvelteKit, while the Apple apps use native Swift and SwiftUI.',
					},
				},
				{
					'@type': 'Question',
					name: 'Does Epic Sax Gandalf collect any personal data?',
					acceptedAnswer: {
						'@type': 'Answer',
						text: 'No. The app collects no personal data, uses no tracking cookies, and requires no account. It only stores your theme preference locally in your browser.',
					},
				},
			],
		},
	},
	'/contact': {
		title: 'Epic Sax Gandalf | Contact',
		description: 'Get in touch with the creator of Epic Sax Gandalf. Find links to website, GitHub, and X (Twitter).',
		path: '/contact',
	},
	'/privacy': {
		title: 'Epic Sax Gandalf | Privacy Policy',
		description: 'Privacy policy for Epic Sax Gandalf. We collect no personal data, use no cookies, and store only your theme preference locally.',
		path: '/privacy',
	},
	'/terms': {
		title: 'Epic Sax Gandalf | Terms of Service',
		description: 'Terms of service for Epic Sax Gandalf — a free, open-source entertainment application.',
		path: '/terms',
	},
	'404': {
		title: 'Page Not Found | Epic Sax Gandalf',
		description: 'The page you are looking for does not exist. Head back to Epic Sax Gandalf and watch Gandalf play the saxophone forever.',
		path: '/',
	},
};
