<script lang="ts">
  import {
    Root as SheetRoot,
    Close as SheetClose,
  } from '$lib/components/ui/sheet';
  import SheetContent from '$lib/components/ui/sheet/SheetContent.svelte';
  import SheetHeader from '$lib/components/ui/sheet/SheetHeader.svelte';
  import SheetTitle from '$lib/components/ui/sheet/SheetTitle.svelte';
  import SheetDescription from '$lib/components/ui/sheet/SheetDescription.svelte';
  import { Button } from '$lib/components/ui/button';
  import { Separator } from '$lib/components/ui/separator';
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

  /** Matching Swift: .sheet(onDismiss: { viewModel.syncVideo() }) */
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
  <SheetContent side="bottom" class="max-h-[70vh] overflow-y-auto !p-6">
    <div class="">
      <SheetClose
        class="inline-flex h-8 w-8 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground fixed top-4 right-4"
      >
        <X size={16} />
      </SheetClose>
      <SheetHeader>
        <SheetTitle class="text-lg font-bold">
          Behold the glory of infinite Gandalf!
        </SheetTitle>
        <SheetDescription class="text-primary font-semibold text-sm">
          Billions must be entertained!
        </SheetDescription>
      </SheetHeader>

      <div class="mt-3 space-y-3 pb-3">
        <!-- Playback -->
        <div>
          <h3 class="text-sm font-medium mb-2">Playback</h3>
          <div class="flex gap-2">
            <Button
              variant={videoState.pauseOnSheetOpen ? 'default' : 'outline'}
              size="sm"
              onclick={() => {
                videoState.pauseOnSheetOpen = true;
                pause();
              }}
              class="flex-1"
            >
              Pause on Open
            </Button>
            <Button
              variant={!videoState.pauseOnSheetOpen ? 'default' : 'outline'}
              size="sm"
              onclick={() => {
                videoState.pauseOnSheetOpen = false;
                play();
              }}
              class="flex-1"
            >
              Keep Playing
            </Button>
          </div>
          <p class="text-muted-foreground text-xs mt-1.5">
            Sets default behavior when opening this panel
          </p>
        </div>

        <Separator />

        <!-- Theme Selection -->
        <div>
          <h3 class="text-sm font-medium mb-2">Theme</h3>
          <div class="flex gap-2">
            <Button
              variant={currentTheme === 'light' ? 'default' : 'outline'}
              size="sm"
              onclick={() => changeTheme('light')}
              class="flex-1 gap-2"
            >
              <Sun size={16} />
              Light
            </Button>
            <Button
              variant={currentTheme === 'dark' ? 'default' : 'outline'}
              size="sm"
              onclick={() => changeTheme('dark')}
              class="flex-1 gap-2"
            >
              <Moon size={16} />
              Dark
            </Button>
            <Button
              variant={currentTheme === 'system' ? 'default' : 'outline'}
              size="sm"
              onclick={() => changeTheme('system')}
              class="flex-1 gap-2"
            >
              <Monitor size={16} />
              System
            </Button>
          </div>
        </div>

        <Separator />

        <!-- Video Source -->
        <div>
          <h3 class="text-sm font-medium mb-2">Video Source</h3>
          <div class="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              onclick={() =>
                window.open('https://youtu.be/BBGEG21CGo0', '_blank')}
              class="flex-1 gap-2"
            >
              <ExternalLink size={16} />
              Original Video
            </Button>
            <Button
              variant="outline"
              size="sm"
              onclick={share}
              class="flex-1 gap-2"
            >
              <Share2 size={16} />
              Share
            </Button>
          </div>
        </div>
      </div>

      <!-- Developer Footer -->
      <Separator class="my-3" />
      <div class="flex flex-col items-center gap-2 py-2">
        <p class="text-xs text-muted-foreground">Built by <span class="font-semibold text-foreground">hmziqrs</span></p>
        <div class="flex items-center gap-3">
          <a
            href="https://hmziq.rs"
            target="_blank"
            rel="noopener noreferrer"
            class="text-muted-foreground transition-colors hover:text-foreground"
            aria-label="Website"
          >
            <Globe size={16} />
          </a>
          <a
            href="https://github.com/hmziqrs"
            target="_blank"
            rel="noopener noreferrer"
            class="text-muted-foreground transition-colors hover:text-foreground"
            aria-label="GitHub"
          >
            <GitHubIcon size={16} />
          </a>
          <a
            href="https://x.com/hmziqrs"
            target="_blank"
            rel="noopener noreferrer"
            class="text-muted-foreground transition-colors hover:text-foreground"
            aria-label="X (Twitter)"
          >
            <XBrandIcon size={16} />
          </a>
        </div>
      </div>
    </div>
  </SheetContent>
</SheetRoot>
