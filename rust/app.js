// ---------------------------------------------------------------------------
// Epic Sax Gandalf — NTP-synced video loop (Tauri v2)
//
// Mirrors the web (Svelte) version exactly:
//   1. Sync NTP once via Rust → get offset in micros
//   2. Seek to (Date.now() + offset) % duration + buffer
//   3. Play. No periodic corrections. Trust the video to loop.
//
// Space resumes by re-seeking to current global position (like web's play()).
// ---------------------------------------------------------------------------

const BUFFER_FIRST_SYNC_SECS = 0.165; // 165ms — matches web & Android
const CURSOR_HIDE_DELAY_MS = 3000;
const DURATION_MICROS = 117_540_000; // 117.54s — hard-coded, same as Rust

let ntpOffsetMicros = 0;
let isPaused = false;
let cursorTimer = null;

const video = document.getElementById('video');
const muteBtn = document.getElementById('mute-btn');
const volumeSlider = document.getElementById('volume');
const syncStatus = document.getElementById('sync-status');

// seek_position = (Date.now() * 1000 + offset) % duration + buffer
// Same formula as web: (Date.now() + offsetMs) % durationMs + BUFFER
function calcSeekSecs(bufferSecs) {
  const deviceMicros = Date.now() * 1000;
  const corrected = deviceMicros + ntpOffsetMicros;
  let raw = (corrected % DURATION_MICROS) + (bufferSecs * 1_000_000);
  // Wrap-around: if adding buffer pushes past duration, wrap back
  if (raw >= DURATION_MICROS) raw -= DURATION_MICROS;
  return raw / 1_000_000;
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
// Init — matches web's VideoPlayer.svelte onMount
// ---------------------------------------------------------------------------

async function init() {
  const { invoke, convertFileSrc } = window.__TAURI__.core;

  // Set video source immediately — let it start buffering in background
  video.src = convertFileSrc('video.mp4', 'gandalf');

  // Fire NTP sync and wait for metadata in parallel — same as web
  const [ntpResult] = await Promise.all([
    invoke('sync_ntp'),
    new Promise((resolve, reject) => {
      video.addEventListener('loadedmetadata', () => resolve(), { once: true });
      video.addEventListener('error', () => {
        reject(new Error('Video load failed: code=' + (video.error ? video.error.code : '?')));
      }, { once: true });
      setTimeout(() => reject(new Error('Metadata timeout')), 10_000);
    }),
  ]);

  ntpOffsetMicros = ntpResult.offset_micros;

  // Seek to synced position — same as web's seekToSyncedPosition()
  video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);

  // Play
  try {
    await video.play();
  } catch (e) {
    console.warn('[gandalf] Autoplay blocked:', e.message);
  }

  syncStatus.textContent = 'Synced';

  // Unmute on first user interaction — matches web's firstPlayUnmute()
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
}

// ---------------------------------------------------------------------------
// Keyboard — Space matches web's play()/pause()
// ---------------------------------------------------------------------------

document.addEventListener('keydown', async (e) => {
  switch (e.code) {
    case 'Space':
      e.preventDefault();
      if (isPaused) {
        // Resume: re-seek to current global position + play (like web's play())
        video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);
        await video.play();
        isPaused = false;
      } else {
        // Pause: just pause (like web's pause())
        video.pause();
        isPaused = true;
      }
      break;

    case 'Escape':
      e.preventDefault();
      try {
        const { invoke } = window.__TAURI__.core;
        await invoke('plugin:window|set_fullscreen', { label: 'main', fullscreen: false });
      } catch (_) {}
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
      } catch (_) {}
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

init().catch(e => {
  console.error('[gandalf]', e);
  syncStatus.textContent = 'Error: ' + e.message;
  syncStatus.style.color = 'red';
});
