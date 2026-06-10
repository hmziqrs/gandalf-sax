// ---------------------------------------------------------------------------
// Epic Sax Gandalf — NTP-synced video loop (Tauri v2)
//
// Rust syncs NTP at startup (raw UDP). JS reads the offset ONCE and does
// all seek math locally. Zero ongoing IPC after that single call.
// ---------------------------------------------------------------------------

const SEEK_POLL_INTERVAL_MS = 1000;
const CURSOR_HIDE_DELAY_MS = 3000;
const BUFFER_FIRST_SYNC_SECS = 0.165;  // 165ms — larger buffer for initial sync
const BUFFER_SECS = 0.025;             // 25ms — tight buffer after first sync

let isPaused = false;
let isFirstSync = true;
let cursorTimer = null;

// NTP state — read once from Rust, used locally forever
let ntpOffsetMicros = 0;
let videoDurationMicros = 0;

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
// Seek position — pure JS math
// seek_position = ((Date.now() * 1000 + ntpOffsetMicros) % duration) + buffer
// ---------------------------------------------------------------------------

function calcSeekSecs(bufferSecs) {
  const deviceMicros = Date.now() * 1000;
  const corrected = deviceMicros + ntpOffsetMicros;
  const seekMicros = (corrected % videoDurationMicros) + (bufferSecs * 1_000_000);
  return seekMicros / 1_000_000;
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
showCursor();

// ---------------------------------------------------------------------------
// Init
// ---------------------------------------------------------------------------

async function init() {
  const { invoke, convertFileSrc } = window.__TAURI__.core;

  // Set video source via custom gandalf:// protocol
  video.src = convertFileSrc('video.mp4', 'gandalf');

  // Wait for enough data buffered for smooth playback
  await new Promise((resolve, reject) => {
    video.addEventListener('canplaythrough', () => resolve(), { once: true });
    video.addEventListener('error', () => {
      const err = video.error;
      reject(new Error('Video load: code=' + (err ? err.code : '?')));
    }, { once: true });
    setTimeout(() => reject(new Error('Video buffer timeout (15s)')), 15_000);
  });

  // ONE Rust call — get the offset from the startup NTP sync
  const ntp = await invoke('get_ntp_state');
  ntpOffsetMicros = ntp.offset_micros;
  videoDurationMicros = ntp.video_duration_micros;

  // Seek to NTP-corrected position
  video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);
  isFirstSync = false;

  syncStatus.textContent = 'Offset: ' + (ntpOffsetMicros / 1000).toFixed(1) + 'ms';

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

  // Seek correction — pure JS, zero IPC, runs every second
  setInterval(() => {
    if (isPaused) return;
    const target = calcSeekSecs(BUFFER_SECS);
    const diff = Math.abs(video.currentTime - target);
    if (diff > 0.5 && diff < 116) {
      video.currentTime = target;
    }
  }, SEEK_POLL_INTERVAL_MS);

  syncStatus.textContent = 'Synced';
  syncStatus.style.color = '';
}

// ---------------------------------------------------------------------------
// Keyboard
// ---------------------------------------------------------------------------

document.addEventListener('keydown', async (e) => {
  switch (e.code) {
    case 'Space':
      e.preventDefault();
      if (isPaused) {
        // Seek to NTP position BEFORE unpausing — atomic, no jerk
        video.currentTime = calcSeekSecs(BUFFER_SECS);
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
        const { invoke } = window.__TAURI__.core;
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
        const { invoke } = window.__TAURI__.core;
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
