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
    firstPlayUnmute,
  } from '$lib/stores.svelte';
  import type { ThemeMode } from '$lib/stores.svelte';
  import {
    logCloseSheet,
    logShareContent,
    logChangeTheme,
    logTogglePauseOnOpen,
    logClickSocialLink,
    logClickOriginalVideo,
  } from '$lib/analytics';

  let { onClose }: { onClose: () => void } = $props();

  let open = $derived(videoState.isSettingsOpen);
  let currentTheme = $derived(getThemeMode());

  function setOpen(val: boolean) {
    videoState.isSettingsOpen = val;
    if (!val) {
      logCloseSheet();
      onClose();
    }
  }

  function changeTheme(mode: ThemeMode) {
    setThemeMode(mode);
    logChangeTheme(mode);
  }

  function share() {
    logShareContent();
    if (navigator.share) {
      navigator.share({
        title: 'Epic Sax Gandalf',
        text: 'Behold the glory of infinite Gandalf!',
        url: 'https://youtu.be/BBGEG21CGo0?ref=gandalf.hmziq.xyz',
      });
    } else {
      navigator.clipboard.writeText('https://youtu.be/BBGEG21CGo0?ref=gandalf.hmziq.xyz');
    }
  }

  function openOriginalVideo() {
    logClickOriginalVideo('settings_sheet');
    window.open('https://youtu.be/BBGEG21CGo0?ref=gandalf.hmziq.xyz', '_blank');
  }
</script>

<!-- Frosted glass + scrollbar: must use :global to target child SheetContent -->
<style>
  :global(.settings-sheet) {
    max-height: 80vh;
    overflow-y: auto;
    border-radius: 1.25rem 1.25rem 0 0 !important;
    padding: 0 !important;
  }
  :global(.settings-sheet)::-webkit-scrollbar { width: 4px; }
  :global(.settings-sheet)::-webkit-scrollbar-track { background: transparent; }
  :global(.settings-sheet)::-webkit-scrollbar-thumb { background: oklch(0 0 0 / 0.1); border-radius: 2px; }
  :global(.dark .settings-sheet)::-webkit-scrollbar-thumb { background: oklch(1 0 0 / 0.1); }

  :global(.shimmer-text) {
    background: linear-gradient(
      90deg,
      oklch(0.52 0.2 30) 0%,
      oklch(0.72 0.22 55) 40%,
      oklch(0.95 0.08 80) 50%,
      oklch(0.72 0.22 55) 60%,
      oklch(0.52 0.2 30) 100%
    );
    background-size: 200% 100%;
    -webkit-background-clip: text;
    background-clip: text;
    -webkit-text-fill-color: transparent;
    animation: shimmer 2.5s ease-in-out infinite;
  }

  @keyframes shimmer {
    0% { background-position: 100% 50%; }
    100% { background-position: -100% 50%; }
  }
</style>

<SheetRoot bind:open onOpenChange={setOpen}>
  <SheetContent side="bottom" class="settings-sheet bg-background/92 backdrop-blur-2xl backdrop-saturate-[1.4] border-t border-primary/15 text-foreground shadow-[0_-8px_40px_oklch(0_0_0/0.5),0_-2px_12px_oklch(0.632_0.18_30/0.06)]">

    <div class="flex flex-col gap-3 p-4 pt-3 pb-5">
      <!-- Close button -->
      <SheetClose
        class="absolute top-4 right-4 z-10 flex h-8 w-8 items-center justify-center rounded-full text-muted-foreground transition-all hover:bg-accent hover:text-accent-foreground"
        aria-label="Close settings"
      >
        <X size={18} />
      </SheetClose>

      <!-- Handle bar -->
      <div class="mx-auto h-1 w-10 rounded-full bg-muted-foreground/15" aria-hidden="true"></div>

      <!-- Header -->
      <div class="text-center pr-8">
        <SheetTitle class="text-lg font-bold tracking-tight">
          Behold the glory of infinite Gandalf!
        </SheetTitle>
        <SheetDescription class="text-xs font-semibold uppercase tracking-wider text-primary mt-0.5">
          Billions must be entertained!
        </SheetDescription>
      </div>

      <!-- Sections -->
      <div class="flex flex-col gap-2">

        <!-- Playback -->
        <section class="rounded-xl border border-border bg-muted/30 p-3 transition-colors hover:border-primary/15">
          <h3 class="mb-2 text-[0.7rem] font-semibold uppercase tracking-widest text-muted-foreground/70">Playback</h3>
          <div class="grid grid-cols-2 gap-2">
            <button
              class={"rounded-lg px-3 py-2 text-sm font-semibold transition-all " + (
                videoState.pauseOnSheetOpen
                  ? "bg-gradient-to-br from-primary to-primary/80 border-transparent text-primary-foreground shadow-[0_2px_8px_oklch(0.52_0.2_30/0.25)]"
                  : "border border-border bg-muted/30 text-muted-foreground hover:border-foreground/20 hover:text-foreground"
              )}
              onclick={() => { videoState.pauseOnSheetOpen = true; pause(); logTogglePauseOnOpen(true); }}
            >
              Pause on Open
            </button>
            <button
              class={"rounded-lg px-3 py-2 text-sm font-semibold transition-all " + (
                !videoState.pauseOnSheetOpen
                  ? "bg-gradient-to-br from-primary to-primary/80 border-transparent text-primary-foreground shadow-[0_2px_8px_oklch(0.52_0.2_30/0.25)]"
                  : "border border-border bg-muted/30 text-muted-foreground hover:border-foreground/20 hover:text-foreground"
              )}
              onclick={() => { videoState.pauseOnSheetOpen = false; play(); firstPlayUnmute(); logTogglePauseOnOpen(false); }}
            >
              Keep Playing
            </button>
          </div>
          <p class="mt-2 text-[0.7rem] text-muted-foreground/60">Default behavior when opening this panel</p>
        </section>

        <!-- Theme -->
        <section class="rounded-xl border border-border bg-muted/30 p-3 transition-colors hover:border-primary/15">
          <h3 class="mb-2 text-[0.7rem] font-semibold uppercase tracking-widest text-muted-foreground/70">Theme</h3>
          <div class="grid grid-cols-3 gap-2">
            <button
              class={"flex flex-col items-center gap-1 rounded-lg px-2 py-2.5 text-[0.7rem] font-semibold transition-all " + (
                currentTheme === 'light'
                  ? "bg-gradient-to-br from-primary to-primary/80 border-transparent text-primary-foreground shadow-[0_2px_8px_oklch(0.52_0.2_30/0.25)]"
                  : "border border-border bg-muted/30 text-muted-foreground hover:border-foreground/20 hover:text-foreground"
              )}
              onclick={() => changeTheme('light')}
              aria-label="Light theme"
            >
              <Sun size={18} />
              <span>Light</span>
            </button>
            <button
              class={"flex flex-col items-center gap-1 rounded-lg px-2 py-2.5 text-[0.7rem] font-semibold transition-all " + (
                currentTheme === 'dark'
                  ? "bg-gradient-to-br from-primary to-primary/80 border-transparent text-primary-foreground shadow-[0_2px_8px_oklch(0.52_0.2_30/0.25)]"
                  : "border border-border bg-muted/30 text-muted-foreground hover:border-foreground/20 hover:text-foreground"
              )}
              onclick={() => changeTheme('dark')}
              aria-label="Dark theme"
            >
              <Moon size={18} />
              <span>Dark</span>
            </button>
            <button
              class={"flex flex-col items-center gap-1 rounded-lg px-2 py-2.5 text-[0.7rem] font-semibold transition-all " + (
                currentTheme === 'system'
                  ? "bg-gradient-to-br from-primary to-primary/80 border-transparent text-primary-foreground shadow-[0_2px_8px_oklch(0.52_0.2_30/0.25)]"
                  : "border border-border bg-muted/30 text-muted-foreground hover:border-foreground/20 hover:text-foreground"
              )}
              onclick={() => changeTheme('system')}
              aria-label="System theme"
            >
              <Monitor size={18} />
              <span>System</span>
            </button>
          </div>
        </section>

        <!-- Video Source -->
        <section class="rounded-xl border border-border bg-muted/30 p-3 transition-colors hover:border-primary/15">
          <h3 class="mb-2 text-[0.7rem] font-semibold uppercase tracking-widest text-muted-foreground/70">Source</h3>
          <div class="grid grid-cols-2 gap-2">
            <button
              class="inline-flex items-center justify-center gap-1.5 rounded-lg border border-border bg-muted/30 px-3 py-2 text-sm font-medium text-muted-foreground transition-all hover:border-foreground/20 hover:bg-muted/50 hover:text-foreground"
              onclick={openOriginalVideo}
            >
              <ExternalLink size={15} />
              Original Video
            </button>
            <button
              class="inline-flex items-center justify-center gap-1.5 rounded-lg border border-border bg-muted/30 px-3 py-2 text-sm font-medium text-muted-foreground transition-all hover:border-foreground/20 hover:bg-muted/50 hover:text-foreground"
              onclick={share}
            >
              <Share2 size={15} />
              Share
            </button>
          </div>
        </section>
      </div>

      <!-- Footer: page links + dev info -->
      <div class="flex flex-wrap items-center justify-center gap-3 pt-2">
        <div class="flex items-center gap-2">
          <a href="/" class="text-[0.7rem] font-medium text-muted-foreground transition-colors hover:text-foreground">Home</a>
          <div class="h-1 w-1 rounded-full bg-primary/60"></div>
          <a href="/about" class="text-[0.7rem] font-medium text-muted-foreground transition-colors hover:text-foreground">About</a>
          <div class="h-1 w-1 rounded-full bg-primary/60"></div>
          <a href="/contact" class="text-[0.7rem] font-medium text-muted-foreground transition-colors hover:text-foreground">Contact</a>
        </div>

        <div class="h-3.5 w-px bg-border"></div>

        <span class="text-[0.7rem] text-muted-foreground">Built by <strong class="font-semibold shimmer-text">hmziqrs</strong></span>

        <div class="h-3.5 w-px bg-border"></div>

        <div class="flex items-center gap-2.5">
          <a href="https://hmziq.rs?ref=gandalf.hmziq.xyz" target="_blank" rel="noopener noreferrer" onclick={() => logClickSocialLink('hmziq.rs', 'https://hmziq.rs?ref=gandalf.hmziq.xyz')} class="text-muted-foreground transition-all hover:text-primary hover:-translate-y-0.5" aria-label="hmziq.rs">
            <Globe size={14} />
          </a>
          <a href="https://hmziq.xyz?ref=gandalf.hmziq.xyz" target="_blank" rel="noopener noreferrer" onclick={() => logClickSocialLink('hmziq.xyz', 'https://hmziq.xyz?ref=gandalf.hmziq.xyz')} class="text-muted-foreground transition-all hover:text-primary hover:-translate-y-0.5" aria-label="hmziq.xyz">
            <Globe size={14} />
          </a>
          <a href="https://github.com/hmziqrs?ref=gandalf.hmziq.xyz" target="_blank" rel="noopener noreferrer" onclick={() => logClickSocialLink('github', 'https://github.com/hmziqrs?ref=gandalf.hmziq.xyz')} class="text-muted-foreground transition-all hover:text-primary hover:-translate-y-0.5" aria-label="GitHub">
            <GitHubIcon size={14} />
          </a>
          <a href="https://x.com/hmziqrs?ref=gandalf.hmziq.xyz" target="_blank" rel="noopener noreferrer" onclick={() => logClickSocialLink('x', 'https://x.com/hmziqrs?ref=gandalf.hmziq.xyz')} class="text-muted-foreground transition-all hover:text-primary hover:-translate-y-0.5" aria-label="X (Twitter)">
            <XBrandIcon size={14} />
          </a>
        </div>
      </div>
    </div>
  </SheetContent>
</SheetRoot>
