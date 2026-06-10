// ---------------------------------------------------------------------------
// Epic Sax Gandalf — NTP-synced video loop (Tauri v2)
// ---------------------------------------------------------------------------

const RESYNC_INTERVAL_MS = 60_000;
const SEEK_POLL_INTERVAL_MS = 1000;
const CURSOR_HIDE_DELAY_MS = 3000;

let isPaused = false;
let isFirstSync = true;
let cursorTimer = null;

const video = document.getElementById('video');
const controls = document.getElementById('controls');
const muteBtn = document.getElementById('mute-btn');
const volumeSlider = document.getElementById('volume');
const syncStatus = document.getElementById('sync-status');

function showError(msg) {
  console.error('[gandalf]', msg);
  syncStatus.textContent = 'Error: ' + msg;
  syncStatus.style.color = 'red';
}

// ---------------------------------------------------------------------------
// Cursor auto-hide
// ---------------------------------------------------------------------------

function showCursor() {
  document.body.classList.add('mouse-active');
  document.body.style.cursor = 'default';
  clearTimeout(cursorTimer);
  cursorTimer = setTimeout(hideCursor, CURSOR_HIDE_DELAY_MS);
}

function hideCursor() {
  document.body.classList.remove('mouse-active');
  document.body.style.cursor = 'none';
}

document.addEventListener('mousemove', showCursor);
showCursor(); // Show cursor initially

// ---------------------------------------------------------------------------
// Init
// ---------------------------------------------------------------------------

async function init() {
  const { invoke, convertFileSrc } = window.__TAURI__.core;

  // Set video source via custom gandalf:// protocol
  video.src = convertFileSrc('video.mp4', 'gandalf');

  // Wait for enough data buffered for smooth playback
  await new Promise((resolve, reject) => {
    // canplaythrough fires when browser estimates it can play without buffering
    video.addEventListener('canplaythrough', () => resolve(), { once: true });
    video.addEventListener('error', () => {
      const err = video.error;
      reject(new Error('Video load: code=' + (err ? err.code : '?')));
    }, { once: true });
    setTimeout(() => reject(new Error('Video buffer timeout (15s)')), 15_000);
  });

  // Initial NTP sync + seek
  await syncAndSeek(invoke);
  isFirstSync = false;

  // Give the decoder a moment after seek to render the target frame
  await new Promise(r => setTimeout(r, 100));

  // Start playback (muted to bypass autoplay restrictions)
  try {
    await video.play();
  } catch (e) {
    console.warn('[gandalf] Autoplay blocked:', e.message);
  }

  // Unmute on first user interaction (WKWebView requires user gesture)
  const unmuteHint = document.getElementById('unmute-hint');
  function unmute() {
    video.muted = false;
    muteBtn.innerHTML = '&#x1f50a;';
    if (unmuteHint) unmuteHint.style.opacity = '0';
    document.removeEventListener('click', unmute);
    document.removeEventListener('keydown', unmute);
  }
  document.addEventListener('click', unmute);
  document.addEventListener('keydown', unmute);

  // Periodic NTP re-sync every 60s
  setInterval(async () => {
    try {
      await invoke('sync_ntp');
      const status = await invoke('get_ntp_status');
      syncStatus.textContent = 'Offset: ' + (status.offset_micros / 1000).toFixed(1) + 'ms';
    } catch (e) { /* ignore */ }
  }, RESYNC_INTERVAL_MS);

  // Periodic seek correction every 1s
  setInterval(async () => {
    if (isPaused) return;
    try {
      const result = await invoke('get_seek_position', { isFirstSync: false });
      const diff = Math.abs(video.currentTime - result.seek_secs);
      if (diff > 0.5 && diff < 116) {
        video.currentTime = result.seek_secs;
      }
    } catch (e) { /* ignore */ }
  }, SEEK_POLL_INTERVAL_MS);

  syncStatus.textContent = 'Synced';
  syncStatus.style.color = '';
}

// ---------------------------------------------------------------------------
// NTP sync + seek
// ---------------------------------------------------------------------------

async function syncAndSeek(invoke) {
  await invoke('sync_ntp');
  const result = await invoke('get_seek_position', { isFirstSync: isFirstSync });
  video.currentTime = result.seek_secs;
  syncStatus.textContent = 'Offset: ' + (result.offset_micros / 1000).toFixed(1) + 'ms';
}

// ---------------------------------------------------------------------------
// Keyboard
// ---------------------------------------------------------------------------

document.addEventListener('keydown', async (e) => {
  const { invoke } = window.__TAURI__.core;
  switch (e.code) {
    case 'Space':
      e.preventDefault();
      if (isPaused) {
        try {
          const result = await invoke('get_seek_position', { isFirstSync: false });
          video.currentTime = result.seek_secs;
        } catch (e) { /* seek failed, still unpause */ }
        await video.play();
        isPaused = false;
      } else {
        video.pause();
        isPaused = true;
      }
      break;

    case 'Escape':
      e.preventDefault();
      try {
        await invoke('plugin:window|set_fullscreen', { label: 'main', fullscreen: false });
      } catch (e) { /* ignore */ }
      break;

    case 'KeyM':
      toggleMute();
      break;

    case 'ArrowUp':
      e.preventDefault();
      video.volume = Math.min(1, video.volume + 0.05);
      volumeSlider.value = video.volume;
      break;

    case 'ArrowDown':
      e.preventDefault();
      video.volume = Math.max(0, video.volume - 0.05);
      volumeSlider.value = video.volume;
      break;

    case 'KeyF':
      e.preventDefault();
      try {
        await invoke('plugin:window|set_fullscreen', { label: 'main', fullscreen: true });
      } catch (e) { /* ignore */ }
      break;
  }
});

// ---------------------------------------------------------------------------
// Volume
// ---------------------------------------------------------------------------

function toggleMute() {
  video.muted = !video.muted;
  muteBtn.innerHTML = video.muted ? '&#x1f507;' : '&#x1f50a;';
}

muteBtn.addEventListener('click', toggleMute);
volumeSlider.addEventListener('input', (e) => {
  video.volume = parseFloat(e.target.value);
  video.muted = video.volume === 0;
  muteBtn.innerHTML = video.muted ? '&#x1f507;' : '&#x1f50a;';
});

// ---------------------------------------------------------------------------
// Boot
// ---------------------------------------------------------------------------

init().catch(e => showError(e.message));
