<script lang="ts">
  import {
    Root as SheetRoot,
    Close as SheetClose,
  } from '$lib/components/ui/sheet';
  import SheetContent from '$lib/components/ui/sheet/SheetContent.svelte';
  import SheetHeader from '$lib/components/ui/sheet/SheetHeader.svelte';
  import SheetTitle from '$lib/components/ui/sheet/SheetTitle.svelte';
  import SheetDescription from '$lib/components/ui/sheet/SheetDescription.svelte';
  import {
    Sun,
    Moon,
    Monitor,
    Globe,
    ExternalLink,
    Share2,
    X,
  } from '@lucide/svelte';
  import GitHubIcon from '$lib/components/icons/GitHub.svelte';
  import XBrandIcon from '$lib/components/icons/XBrand.svelte';
  import {
    videoState,
    getThemeMode,
    setThemeMode,
    pause,
    play,
  } from '$lib/stores.svelte';
  import type { ThemeMode } from '$lib/stores.svelte';

  let { onClose }: { onClose: () => void } = $props();

  let open = $derived(videoState.isSettingsOpen);
  let currentTheme = $derived(getThemeMode());

  function setOpen(val: boolean) {
    videoState.isSettingsOpen = val;
    if (!val) {
      onClose();
    }
  }

  function changeTheme(mode: ThemeMode) {
    setThemeMode(mode);
  }

  function share() {
    if (navigator.share) {
      navigator.share({
        title: 'Epic Sax Gandalf',
        text: 'Behold the glory of infinite Gandalf!',
        url: 'https://youtu.be/BBGEG21CGo0',
      });
    } else {
      navigator.clipboard.writeText('https://youtu.be/BBGEG21CGo0');
    }
  }
</script>

<SheetRoot bind:open onOpenChange={setOpen}>
  <SheetContent side="bottom" class="settings-sheet">
    <div class="sheet-inner">
      <!-- Close button -->
      <SheetClose class="sheet-close" aria-label="Close settings">
        <X size={18} />
      </SheetClose>

      <!-- Handle bar -->
      <div class="sheet-handle" aria-hidden="true"></div>

      <!-- Header -->
      <div class="sheet-header">
        <SheetTitle class="sheet-title">
          Behold the glory of infinite Gandalf!
        </SheetTitle>
        <SheetDescription class="sheet-subtitle">
          Billions must be entertained!
        </SheetDescription>
      </div>

      <!-- Sections -->
      <div class="sheet-sections">

        <!-- Playback -->
        <section class="sheet-card">
          <h3 class="card-label">Playback</h3>
          <div class="card-body">
            <div class="toggle-group">
              <button
                class="toggle-btn"
                class:active={videoState.pauseOnSheetOpen}
                onclick={() => {
                  videoState.pauseOnSheetOpen = true;
                  pause();
                }}
              >
                Pause on Open
              </button>
              <button
                class="toggle-btn"
                class:active={!videoState.pauseOnSheetOpen}
                onclick={() => {
                  videoState.pauseOnSheetOpen = false;
                  play();
                }}
              >
                Keep Playing
              </button>
            </div>
            <p class="card-hint">Default behavior when opening this panel</p>
          </div>
        </section>

        <!-- Theme -->
        <section class="sheet-card">
          <h3 class="card-label">Theme</h3>
          <div class="card-body">
            <div class="theme-group">
              <button
                class="theme-btn"
                class:active={currentTheme === 'light'}
                onclick={() => changeTheme('light')}
                aria-label="Light theme"
              >
                <Sun size={18} />
                <span>Light</span>
              </button>
              <button
                class="theme-btn"
                class:active={currentTheme === 'dark'}
                onclick={() => changeTheme('dark')}
                aria-label="Dark theme"
              >
                <Moon size={18} />
                <span>Dark</span>
              </button>
              <button
                class="theme-btn"
                class:active={currentTheme === 'system'}
                onclick={() => changeTheme('system')}
                aria-label="System theme"
              >
                <Monitor size={18} />
                <span>System</span>
              </button>
            </div>
          </div>
        </section>

        <!-- Video Source -->
        <section class="sheet-card">
          <h3 class="card-label">Source</h3>
          <div class="card-body">
            <div class="source-group">
              <button
                class="source-btn"
                onclick={() => window.open('https://youtu.be/BBGEG21CGo0', '_blank')}
              >
                <ExternalLink size={15} />
                Original Video
              </button>
              <button
                class="source-btn"
                onclick={share}
              >
                <Share2 size={15} />
                Share
              </button>
            </div>
          </div>
        </section>
      </div>

      <!-- Page links + Developer Footer -->
      <div class="footer-row">
        <div class="page-links">
          <a href="/home" class="page-link">Home</a>
          <div class="page-dot"></div>
          <a href="/about" class="page-link">About</a>
          <div class="page-dot"></div>
          <a href="/contact" class="page-link">Contact</a>
        </div>
        <div class="dev-sep"></div>
        <span class="dev-text">Built by <strong class="dev-name">hmziqrs</strong></span>
        <div class="dev-sep"></div>
        <div class="dev-links">
          <a
            href="https://hmziq.rs"
            target="_blank"
            rel="noopener noreferrer"
            class="dev-link"
            aria-label="Website"
          >
            <Globe size={14} />
          </a>
          <a
            href="https://github.com/hmziqrs"
            target="_blank"
            rel="noopener noreferrer"
            class="dev-link"
            aria-label="GitHub"
          >
            <GitHubIcon size={14} />
          </a>
          <a
            href="https://x.com/hmziqrs"
            target="_blank"
            rel="noopener noreferrer"
            class="dev-link"
            aria-label="X (Twitter)"
          >
            <XBrandIcon size={14} />
          </a>
        </div>
      </div>
    </div>
  </SheetContent>
</SheetRoot>

<style>
  /* ── Shared palette using CSS vars that auto-switch light/dark ── */
  :root {
    --sheet-bg: oklch(1 0 0 / 0.94);
    --sheet-fg: oklch(0.145 0 0);
    --sheet-muted: oklch(0.556 0.015 254.604);
    --sheet-muted-strong: oklch(0.45 0.015 254.604);
    --sheet-card-bg: oklch(0 0 0 / 0.03);
    --sheet-card-border: oklch(0 0 0 / 0.06);
    --sheet-card-hover: oklch(0.632 0.218 19.362 / 0.15);
    --sheet-btn-bg: oklch(0 0 0 / 0.03);
    --sheet-btn-border: oklch(0 0 0 / 0.08);
    --sheet-btn-fg: oklch(0 0 0 / 0.55);
    --sheet-btn-hover-fg: oklch(0 0 0 / 0.8);
    --sheet-handle: oklch(0 0 0 / 0.12);
    --sheet-overlay-border: oklch(0.632 0.218 19.362 / 0.2);
    --sheet-close-fg: oklch(0 0 0 / 0.35);
    --sheet-close-hover-fg: oklch(0 0 0 / 0.8);
    --sheet-close-hover-bg: oklch(0 0 0 / 0.05);
    --sheet-accent: oklch(0.632 0.218 19.362);
    --sheet-accent-text: oklch(0.541 0.197 18.772);
    --sheet-scroll-thumb: oklch(0 0 0 / 0.1);
    --sheet-pill-bg: oklch(0 0 0 / 0.02);
    --sheet-pill-border: oklch(0 0 0 / 0.05);
  }

  :global(.dark) {
    --sheet-bg: oklch(0.145 0 0 / 0.92);
    --sheet-fg: oklch(0.985 0 0);
    --sheet-muted: oklch(0.7 0.015 254.604);
    --sheet-muted-strong: oklch(0.55 0.015 254.604);
    --sheet-card-bg: oklch(1 0 0 / 0.04);
    --sheet-card-border: oklch(1 0 0 / 0.06);
    --sheet-card-hover: oklch(0.632 0.218 19.362 / 0.12);
    --sheet-btn-bg: oklch(1 0 0 / 0.03);
    --sheet-btn-border: oklch(1 0 0 / 0.08);
    --sheet-btn-fg: oklch(1 0 0 / 0.5);
    --sheet-btn-hover-fg: oklch(1 0 0 / 0.8);
    --sheet-handle: oklch(1 0 0 / 0.15);
    --sheet-overlay-border: oklch(0.632 0.218 19.362 / 0.15);
    --sheet-close-fg: oklch(1 0 0 / 0.4);
    --sheet-close-hover-fg: oklch(1 0 0 / 0.9);
    --sheet-close-hover-bg: oklch(1 0 0 / 0.08);
    --sheet-accent: oklch(0.78 0.16 55);
    --sheet-accent-text: oklch(0.78 0.16 55);
    --sheet-scroll-thumb: oklch(1 0 0 / 0.1);
    --sheet-pill-bg: oklch(1 0 0 / 0.03);
    --sheet-pill-border: oklch(1 0 0 / 0.05);
  }

  /* ── Frosted glass container ── */
  :global(.settings-sheet) {
    max-height: 80vh;
    overflow-y: auto;
    background: var(--sheet-bg) !important;
    backdrop-filter: blur(24px) saturate(1.4) !important;
    -webkit-backdrop-filter: blur(24px) saturate(1.4) !important;
    border-top: 1px solid var(--sheet-overlay-border) !important;
    border-radius: 1.25rem 1.25rem 0 0 !important;
    padding: 0 !important;
    color: var(--sheet-fg);
  }

  :global(.dark .settings-sheet) {
    box-shadow: 0 -8px 40px oklch(0 0 0 / 0.5), 0 -2px 12px oklch(0.632 0.18 30 / 0.06);
  }

  :global(.settings-sheet)::-webkit-scrollbar {
    width: 4px;
  }
  :global(.settings-sheet)::-webkit-scrollbar-track {
    background: transparent;
  }
  :global(.settings-sheet)::-webkit-scrollbar-thumb {
    background: var(--sheet-scroll-thumb);
    border-radius: 2px;
  }

  .sheet-inner {
    padding: 1rem 1.25rem 1.25rem;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  /* Drag handle */
  .sheet-handle {
    width: 2.5rem;
    height: 4px;
    border-radius: 2px;
    background: var(--sheet-handle);
    margin: 0 auto 0.25rem;
  }

  /* Close button */
  :global(.settings-sheet .sheet-close) {
    position: absolute;
    top: 1rem;
    right: 1rem;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 2rem;
    height: 2rem;
    border-radius: 50%;
    color: var(--sheet-close-fg);
    background: transparent;
    border: none;
    cursor: pointer;
    transition: all 0.2s ease;
    z-index: 5;
  }

  :global(.settings-sheet .sheet-close):hover {
    color: var(--sheet-close-hover-fg);
    background: var(--sheet-close-hover-bg);
  }

  /* Header */
  .sheet-header {
    text-align: center;
    padding-right: 2rem;
  }

  .sheet-header :global(.sheet-title) {
    font-size: 1.1rem;
    font-weight: 700;
    color: var(--sheet-fg);
    letter-spacing: -0.01em;
    line-height: 1.3;
  }

  .sheet-header :global(.sheet-subtitle) {
    font-size: 0.8rem;
    font-weight: 600;
    color: var(--sheet-accent-text);
    margin-top: 0.15rem;
    letter-spacing: 0.02em;
    text-transform: uppercase;
  }

  /* Section cards */
  .sheet-sections {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .sheet-card {
    background: var(--sheet-card-bg);
    border: 1px solid var(--sheet-card-border);
    border-radius: 0.75rem;
    padding: 0.75rem;
    transition: border-color 0.2s ease;
  }

  .sheet-card:hover {
    border-color: var(--sheet-card-hover);
  }

  .card-label {
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--sheet-muted-strong);
    margin-bottom: 0.5rem;
  }

  .card-body {
    display: flex;
    flex-direction: column;
  }

  .card-hint {
    font-size: 0.7rem;
    color: var(--sheet-muted);
    margin-top: 0.5rem;
  }

  /* Playback toggle buttons */
  .toggle-group {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 0.5rem;
  }

  .toggle-btn {
    padding: 0.5rem 0.75rem;
    border-radius: 0.5rem;
    font-size: 0.8rem;
    font-weight: 600;
    font-family: inherit;
    cursor: pointer;
    transition: all 0.2s ease;
    border: 1px solid var(--sheet-btn-border);
    background: var(--sheet-btn-bg);
    color: var(--sheet-btn-fg);
  }

  .toggle-btn:hover {
    border-color: var(--sheet-btn-hover-fg);
    color: var(--sheet-btn-hover-fg);
  }

  .toggle-btn.active {
    background: linear-gradient(135deg, oklch(0.58 0.2 30), oklch(0.52 0.18 45));
    border-color: transparent;
    color: white;
    box-shadow: 0 2px 8px oklch(0.52 0.2 30 / 0.25), inset 0 1px 0 oklch(1 0 0 / 0.1);
  }

  /* Theme selector */
  .theme-group {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 0.5rem;
  }

  .theme-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.35rem;
    padding: 0.6rem 0.5rem;
    border-radius: 0.5rem;
    font-size: 0.7rem;
    font-weight: 600;
    font-family: inherit;
    cursor: pointer;
    transition: all 0.2s ease;
    border: 1px solid var(--sheet-btn-border);
    background: var(--sheet-btn-bg);
    color: var(--sheet-btn-fg);
  }

  .theme-btn:hover {
    border-color: var(--sheet-btn-hover-fg);
    color: var(--sheet-btn-hover-fg);
  }

  .theme-btn.active {
    background: linear-gradient(135deg, oklch(0.58 0.2 30), oklch(0.52 0.18 45));
    border-color: transparent;
    color: white;
    box-shadow: 0 2px 8px oklch(0.52 0.2 30 / 0.25), inset 0 1px 0 oklch(1 0 0 / 0.1);
  }

  /* Source buttons */
  .source-group {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 0.5rem;
  }

  .source-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.4rem;
    padding: 0.5rem 0.75rem;
    border-radius: 0.5rem;
    font-size: 0.8rem;
    font-weight: 500;
    font-family: inherit;
    cursor: pointer;
    transition: all 0.2s ease;
    border: 1px solid var(--sheet-btn-border);
    background: var(--sheet-btn-bg);
    color: var(--sheet-btn-fg);
  }

  .source-btn:hover {
    border-color: var(--sheet-btn-hover-fg);
    color: var(--sheet-btn-hover-fg);
    background: var(--sheet-card-bg);
  }

  /* Footer row: page links + dev info */
  .footer-row {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.75rem;
    padding-top: 0.5rem;
    flex-wrap: wrap;
  }

  .page-links {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .page-dot {
    width: 4px;
    height: 4px;
    border-radius: 50%;
    background: var(--sheet-accent-text);
    opacity: 0.6;
    flex-shrink: 0;
  }

  .page-link {
    font-size: 0.7rem;
    font-weight: 500;
    color: var(--sheet-muted);
    text-decoration: none;
    transition: color 0.2s ease;
  }

  .page-link:hover {
    color: var(--sheet-fg);
  }

  .dev-text {
    font-size: 0.7rem;
    color: var(--sheet-muted);
  }

  .dev-name {
    color: var(--sheet-accent-text);
    font-weight: 600;
  }

  .dev-sep {
    width: 1px;
    height: 0.875rem;
    background: var(--sheet-card-border);
  }

  .dev-links {
    display: flex;
    align-items: center;
    gap: 0.6rem;
  }

  .dev-link {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    color: var(--sheet-muted);
    transition: all 0.2s ease;
    padding: 0.15rem;
  }

  .dev-link:hover {
    color: var(--sheet-accent);
    transform: translateY(-1px);
  }
</style>
