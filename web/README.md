# Epic Sax Gandalf — Web

The web version of [Epic Sax Gandalf](https://github.com/hmziqrs/gandalf-sax), built with **SvelteKit** and **shadcn-svelte**. Plays the Epic Sax Gandalf video on an infinite seamless loop with NTP time synchronization across all devices.

## Features

- 🎵 Infinite seamless video loop
- 🕐 NTP time synchronization (all devices see the same frame)
- 🎨 Light / Dark / System theme support
- ⌨️ Keyboard shortcuts (F for fullscreen, Escape to exit)
- 📱 PWA manifest for install-to-homescreen
- 🔗 Social links and share functionality

## Tech Stack

- [SvelteKit](https://kit.svelte.dev/) — Framework
- [shadcn-svelte](https://shadcn-svelte.com/) — UI components
- [Tailwind CSS v4](https://tailwindcss.com/) — Styling
- [bits-ui](https://bits-ui.com/) — Headless UI primitives
- [@lucide/svelte](https://lucide.dev/) — Icons

## Developing

```sh
cd web
npm install
npm run dev
```

## Building

```sh
npm run build
```

The static output is written to `build/`. Preview with:

```sh
npm run preview
```

## Project Structure

```
web/
├── src/
│   ├── app.html              # HTML shell
│   ├── app.css               # Tailwind + theme variables
│   ├── lib/
│   │   ├── ntp.ts            # NTP client (matches native impls)
│   │   ├── stores.ts         # Svelte stores (video state, theme)
│   │   ├── utils.ts          # cn() utility
│   │   └── components/
│   │       ├── VideoPlayer.svelte   # Fullscreen video + sync
│   │       ├── SettingsSheet.svelte # Bottom sheet settings
│   │       └── ui/                  # shadcn-svelte components
│   └── routes/
│       ├── +layout.svelte    # Root layout with theme
│       ├── +layout.ts        # Prerender config
│       └── +page.svelte      # Main page
├── static/
│   ├── video.mp4             # Source video
│   ├── logo.png              # App icon
│   └── manifest.json         # PWA manifest
└── build/                    # Production output
```

## License

MIT
