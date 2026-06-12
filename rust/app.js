// ---------------------------------------------------------------------------
// Epic Sax Gandalf — NTP-synced video loop (Tauri v2)
//
// Mirrors the web (Svelte) version exactly:
//   1. Sync NTP once via Rust -> get offset in micros
//   2. Seek to (Date.now() + offset) % duration + buffer
//   3. Play. No periodic corrections. Trust the video to loop.
//
// Space resumes by re-seeking to current global position (like web's play()).
// ---------------------------------------------------------------------------

(function () {
  'use strict';

  // --- Constants ---
  var BUFFER_FIRST_SYNC_SECS = 0.165; // 165ms — matches web & Android
  var CURSOR_HIDE_DELAY_MS = 3000;
  var DURATION_MICROS = 117_540_000; // 117.54s — hard-coded, same as Rust
  var YOUTUBE_URL = 'https://www.youtube.com/watch?v=gy1B3agGNxw';
  var SHARE_TEXT = 'Epic Sax Gandalf — NTP-synced video loop https://github.com/hmziqrs/gandalf-sax';

  // --- State ---
  var ntpOffsetMicros = 0;
  var isSynced = false;
  var isPaused = false;
  var sheetOpen = false;
  var hasPlayedOnce = false;
  var isFullscreen = false;
  var cursorTimer = null;

  // --- Settings (persisted to localStorage) ---
  var settings = {
    theme: localStorage.getItem('gandalf_theme') || 'system',
    pauseOnSheetOpen: localStorage.getItem('gandalf_pause_on_open') !== 'false'
  };

  // --- DOM refs ---
  var video = document.getElementById('video');
  var videoContainer = document.getElementById('video-container');
  var controls = document.getElementById('controls');
  var muteBtn = document.getElementById('mute-btn');
  var volumeSlider = document.getElementById('volume');
  var syncStatus = document.getElementById('sync-status');
  var unmuteHint = document.getElementById('unmute-hint');
  var sheetBackdrop = document.getElementById('sheet-backdrop');
  var sheet = document.getElementById('sheet');
  var closeSheetBtn = document.getElementById('close-sheet');
  var syncDot = document.getElementById('sync-dot');
  var syncLabel = document.getElementById('sync-label');
  var togglePause = document.getElementById('toggle-pause');
  var toggleKeep = document.getElementById('toggle-keep');
  var themeLight = document.getElementById('theme-light');
  var themeDark = document.getElementById('theme-dark');
  var themeSystem = document.getElementById('theme-system');
  var btnVideo = document.getElementById('btn-video');
  var btnShare = document.getElementById('btn-share');
  var shareFeedback = document.getElementById('share-feedback');
  var fullscreenBtn = document.getElementById('fullscreen-btn');

  // --- Tauri helpers ---
  var core = window.__TAURI__.core;
  var invoke = core.invoke;
  var convertFileSrc = core.convertFileSrc;

  // ---------------------------------------------------------------------------
  // Seek formula — same as web version
  // ---------------------------------------------------------------------------

  function calcSeekSecs(bufferSecs) {
    var deviceMicros = Date.now() * 1000;
    var corrected = deviceMicros + ntpOffsetMicros;
    var raw = (corrected % DURATION_MICROS) + (bufferSecs * 1_000_000);
    // Wrap-around: if adding buffer pushes past duration, wrap back
    if (raw >= DURATION_MICROS) raw -= DURATION_MICROS;
    return raw / 1_000_000;
  }

  // ---------------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------------

  var systemDarkQuery = window.matchMedia('(prefers-color-scheme: dark)');
  var systemThemeHandler = null;

  function applyTheme(mode) {
    document.documentElement.setAttribute('data-theme', mode === 'system'
      ? (systemDarkQuery.matches ? 'dark' : 'light')
      : mode);

    // Remove old system listener if any
    if (systemThemeHandler) {
      systemDarkQuery.removeEventListener('change', systemThemeHandler);
      systemThemeHandler = null;
    }

    // Listen for system changes when mode is 'system'
    if (mode === 'system') {
      systemThemeHandler = function (e) {
        document.documentElement.setAttribute('data-theme', e.matches ? 'dark' : 'light');
      };
      systemDarkQuery.addEventListener('change', systemThemeHandler);
    }

    // Update active class on theme buttons
    [themeLight, themeDark, themeSystem].forEach(function (btn) {
      if (!btn) return;
      btn.classList.toggle('active', btn ===
        (mode === 'light' ? themeLight : mode === 'dark' ? themeDark : themeSystem));
    });
  }

  function initTheme() {
    var saved = localStorage.getItem('gandalf_theme') || 'system';
    settings.theme = saved;
    applyTheme(saved);
  }

  // ---------------------------------------------------------------------------
  // Playback toggle
  // ---------------------------------------------------------------------------

  function updatePlaybackToggle() {
    if (togglePause) togglePause.classList.toggle('active', settings.pauseOnSheetOpen);
    if (toggleKeep) toggleKeep.classList.toggle('active', !settings.pauseOnSheetOpen);
  }

  // ---------------------------------------------------------------------------
  // Sheet
  // ---------------------------------------------------------------------------

  function openSheet() {
    if (sheetBackdrop) sheetBackdrop.classList.add('active');
    if (sheet) sheet.classList.add('active');
    if (settings.pauseOnSheetOpen) {
      video.pause();
    }
    sheetOpen = true;
    // Stop cursor hide timer while sheet is open
    clearTimeout(cursorTimer);
    document.body.classList.add('mouse-active');
    document.body.style.cursor = 'default';
  }

  function closeSheet() {
    if (sheetBackdrop) sheetBackdrop.classList.remove('active');
    if (sheet) sheet.classList.remove('active');
    sheetOpen = false;

    if (!isPaused) {
      // Re-seek to synced position and play
      video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);
      video.play().catch(function () {});
    }

    // On FIRST close, unmute video
    if (!hasPlayedOnce) {
      video.muted = false;
      if (muteBtn) muteBtn.innerHTML = '&#x1f50a;';
      hasPlayedOnce = true;
    }
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
    if (sheetOpen) return;
    document.body.classList.remove('mouse-active');
    document.body.style.cursor = 'none';
  }

  // ---------------------------------------------------------------------------
  // Mute / Volume
  // ---------------------------------------------------------------------------

  function toggleMute() {
    video.muted = !video.muted;
    if (muteBtn) muteBtn.innerHTML = video.muted ? '&#x1f507;' : '&#x1f50a;';
  }

  // ---------------------------------------------------------------------------
  // Fullscreen
  // ---------------------------------------------------------------------------

  function toggleFullscreen() {
    isFullscreen = !isFullscreen;
    invoke('plugin:window|set_fullscreen', { label: 'main', fullscreen: isFullscreen }).catch(function () {});
    if (fullscreenBtn) fullscreenBtn.innerHTML = isFullscreen ? '&#x2921;' : '&#x2922;';
  }

  // ---------------------------------------------------------------------------
  // Init — matches web's VideoPlayer.svelte onMount
  // ---------------------------------------------------------------------------

  async function init() {
    // a. Apply theme immediately
    initTheme();

    // b. Update playback toggle state
    updatePlaybackToggle();

    // c. Set video source
    video.src = convertFileSrc('video.mp4', 'gandalf');

    // d. Fire NTP sync and wait for metadata in parallel
    var ntpResult;
    var metadataPromise = new Promise(function (resolve, reject) {
      video.addEventListener('loadedmetadata', function () { resolve(); }, { once: true });
      video.addEventListener('error', function () {
        reject(new Error('Video load failed: code=' + (video.error ? video.error.code : '?')));
      }, { once: true });
      setTimeout(function () { reject(new Error('Metadata timeout')); }, 10_000);
    });

    var results = await Promise.all([
      invoke('sync_ntp'),
      metadataPromise
    ]);
    ntpResult = results[0];

    // e. Store ntpOffsetMicros, set isSynced
    ntpOffsetMicros = ntpResult.offset_micros;
    isSynced = true;

    // f. Update sync-dot and sync-label
    if (syncDot) syncDot.style.background = '#22c55e';
    if (syncLabel) syncLabel.textContent = 'NTP';

    // g. Seek to synced position
    video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);

    // h. Play
    try {
      await video.play();
    } catch (e) {
      console.warn('[gandalf] Autoplay blocked:', e.message);
    }

    // i. Update syncStatus
    if (syncStatus) syncStatus.textContent = 'Synced';

    // j. Unmute on first user interaction
    function unmute() {
      video.muted = false;
      if (muteBtn) muteBtn.innerHTML = '&#x1f50a;';
      if (unmuteHint) unmuteHint.style.opacity = '0';
      document.removeEventListener('click', unmute);
      document.removeEventListener('keydown', unmute);
    }
    document.addEventListener('click', unmute);
    document.addEventListener('keydown', unmute);
  }

  // ---------------------------------------------------------------------------
  // Event listeners
  // ---------------------------------------------------------------------------

  // video-container click -> openSheet (but NOT if clicking controls)
  if (videoContainer) {
    videoContainer.addEventListener('click', function () {
      openSheet();
    });
  }

  // controls click -> stopPropagation (prevents opening sheet)
  if (controls) {
    controls.addEventListener('click', function (e) {
      e.stopPropagation();
    });
  }

  // sheet-backdrop click -> closeSheet
  if (sheetBackdrop) {
    sheetBackdrop.addEventListener('click', function () {
      closeSheet();
    });
  }

  // close-sheet click -> closeSheet
  if (closeSheetBtn) {
    closeSheetBtn.addEventListener('click', function () {
      closeSheet();
    });
  }

  // toggle-pause click
  if (togglePause) {
    togglePause.addEventListener('click', function () {
      settings.pauseOnSheetOpen = true;
      localStorage.setItem('gandalf_pause_on_open', 'true');
      updatePlaybackToggle();
    });
  }

  // toggle-keep click
  if (toggleKeep) {
    toggleKeep.addEventListener('click', function () {
      settings.pauseOnSheetOpen = false;
      localStorage.setItem('gandalf_pause_on_open', 'false');
      updatePlaybackToggle();
    });
  }

  // theme buttons
  if (themeLight) {
    themeLight.addEventListener('click', function () {
      settings.theme = 'light';
      localStorage.setItem('gandalf_theme', 'light');
      applyTheme('light');
    });
  }
  if (themeDark) {
    themeDark.addEventListener('click', function () {
      settings.theme = 'dark';
      localStorage.setItem('gandalf_theme', 'dark');
      applyTheme('dark');
    });
  }
  if (themeSystem) {
    themeSystem.addEventListener('click', function () {
      settings.theme = 'system';
      localStorage.setItem('gandalf_theme', 'system');
      applyTheme('system');
    });
  }

  // btn-video click -> open YouTube URL
  if (btnVideo) {
    btnVideo.addEventListener('click', function () {
      invoke('open_url', { url: YOUTUBE_URL }).catch(function () {});
    });
  }

  // btn-share click -> copy to clipboard
  if (btnShare) {
    btnShare.addEventListener('click', function () {
      navigator.clipboard.writeText(SHARE_TEXT).then(function () {
        if (shareFeedback) {
          shareFeedback.style.display = 'inline';
          setTimeout(function () { shareFeedback.style.display = 'none'; }, 2000);
        }
      }).catch(function () {});
    });
  }

  // social-link click (delegated on sheet)
  if (sheet) {
    sheet.addEventListener('click', function (e) {
      var link = e.target.closest('a[data-url]');
      if (link) {
        e.preventDefault();
        var url = link.dataset.url;
        if (url) invoke('open_url', { url: url }).catch(function () {});
      }
    });
  }

  // fullscreen-btn click
  if (fullscreenBtn) {
    fullscreenBtn.addEventListener('click', function () {
      toggleFullscreen();
    });
  }

  // mute-btn click
  if (muteBtn) {
    muteBtn.addEventListener('click', function () {
      toggleMute();
    });
  }

  // volume input
  if (volumeSlider) {
    volumeSlider.addEventListener('input', function (e) {
      video.volume = parseFloat(e.target.value);
      video.muted = video.volume === 0;
      if (muteBtn) muteBtn.innerHTML = video.muted ? '&#x1f507;' : '&#x1f50a;';
    });
  }

  // mousemove -> show cursor, 3s timer to hide
  document.addEventListener('mousemove', function () {
    if (sheetOpen) return;
    showCursor();
  });
  showCursor();

  // ---------------------------------------------------------------------------
  // Keyboard handler
  // ---------------------------------------------------------------------------

  document.addEventListener('keydown', async function (e) {
    switch (e.code) {
      case 'Space':
        e.preventDefault();
        if (sheetOpen) return;
        if (isPaused) {
          // Resume: re-seek to current global position + play
          video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);
          await video.play().catch(function () {});
          isPaused = false;
        } else {
          video.pause();
          isPaused = true;
        }
        break;

      case 'Escape':
        e.preventDefault();
        if (sheetOpen) {
          closeSheet();
        } else {
          // Exit fullscreen
          isFullscreen = false;
          invoke('plugin:window|set_fullscreen', { label: 'main', fullscreen: false }).catch(function () {});
          if (fullscreenBtn) fullscreenBtn.innerHTML = '&#x2922;';
        }
        break;

      case 'KeyM':
        toggleMute();
        break;

      case 'KeyF':
        e.preventDefault();
        toggleFullscreen();
        break;

      case 'ArrowUp':
        e.preventDefault();
        video.volume = Math.min(1, video.volume + 0.05);
        if (volumeSlider) volumeSlider.value = video.volume;
        break;

      case 'ArrowDown':
        e.preventDefault();
        video.volume = Math.max(0, video.volume - 0.05);
        if (volumeSlider) volumeSlider.value = video.volume;
        break;
    }
  });

  // ---------------------------------------------------------------------------
  // Boot
  // ---------------------------------------------------------------------------

  init().catch(function (e) {
    console.error('[gandalf]', e);
    if (syncStatus) {
      syncStatus.textContent = 'Error: ' + e.message;
      syncStatus.style.color = 'red';
    }
  });

})();
