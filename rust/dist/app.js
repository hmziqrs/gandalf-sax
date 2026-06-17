(function () {
  'use strict';

  // --- Constants ---
  var BUFFER_FIRST_SYNC_SECS = 0.165;
  var CURSOR_HIDE_DELAY_MS = 3000;
  var YOUTUBE_URL = 'https://www.youtube.com/watch?v=gy1B3agGNxw';
  var SHARE_TEXT = 'Epic Sax Gandalf — NTP-synced video loop https://github.com/hmziqrs/gandalf-sax';

  // --- SVG icon templates ---
  var SVG_VOLUME_ON = '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/></svg>';
  var SVG_VOLUME_LOW = '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/></svg>';
  var SVG_VOLUME_OFF = '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><line x1="23" y1="9" x2="17" y2="15"/><line x1="17" y1="9" x2="23" y2="15"/></svg>';
  var SVG_MAXIMIZE = '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><polyline points="15 3 21 3 21 9"/><polyline points="9 21 3 21 3 15"/><line x1="21" y1="3" x2="14" y2="10"/><line x1="3" y1="21" x2="10" y2="14"/></svg>';
  var SVG_MINIMIZE = '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><polyline points="4 14 10 14 10 20"/><polyline points="20 10 14 10 14 4"/><line x1="14" y1="10" x2="21" y2="3"/><line x1="3" y1="21" x2="10" y2="14"/></svg>';

  // --- State ---
  var ntpOffsetMicros = 0;
  var durationMicros = 0;
  var isSynced = false;
  var sheetOpen = false;
  var hasPlayedOnce = false;
  var isFullscreen = false;
  var ready = false;
  var cursorTimer = null;
  var lastFocused = null;          // element to return focus to when the sheet closes
  var fullscreenInFlight = false;  // serialize rapid fullscreen toggles

  var settings = {
    theme: localStorage.getItem('gandalf_theme') || 'system',
    pauseOnSheetOpen: localStorage.getItem('gandalf_pause_on_open') !== 'false'
  };

  // --- DOM ---
  var video = document.getElementById('video');
  var videoContainer = document.getElementById('video-container');
  var controls = document.getElementById('controls');
  var muteBtn = document.getElementById('mute-btn');
  var volumeSlider = document.getElementById('volume');
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

  var invoke = window.__TAURI__.core.invoke;
  var convertFileSrc = window.__TAURI__.core.convertFileSrc;

  // ---------------------------------------------------------------------------
  // Seek formula
  // ---------------------------------------------------------------------------

  function calcSeekSecs(bufferSecs) {
    if (!durationMicros) return 0; // guard pre-init (metadata not loaded yet)
    var deviceMicros = Date.now() * 1000;
    var corrected = deviceMicros + ntpOffsetMicros;
    var raw = (corrected % durationMicros) + (bufferSecs * 1_000_000);
    if (raw >= durationMicros) raw -= durationMicros;
    return raw / 1_000_000;
  }

  // ---------------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------------

  var systemDarkQuery = window.matchMedia('(prefers-color-scheme: dark)');
  var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var systemThemeHandler = null;

  function applyTheme(mode) {
    var resolved = mode === 'system'
      ? (systemDarkQuery.matches ? 'dark' : 'light') : mode;
    document.documentElement.classList.toggle('dark', resolved === 'dark');

    if (systemThemeHandler) {
      systemDarkQuery.removeEventListener('change', systemThemeHandler);
      systemThemeHandler = null;
    }
    if (mode === 'system') {
      systemThemeHandler = function (e) {
        document.documentElement.classList.toggle('dark', e.matches);
      };
      systemDarkQuery.addEventListener('change', systemThemeHandler);
    }

    var active = mode === 'light' ? themeLight : mode === 'dark' ? themeDark : themeSystem;
    [themeLight, themeDark, themeSystem].forEach(function (btn) {
      if (btn) btn.classList.toggle('active', btn === active);
    });
  }

  function initTheme() {
    applyTheme(localStorage.getItem('gandalf_theme') || 'system');
  }

  // ---------------------------------------------------------------------------
  // Playback toggle
  // ---------------------------------------------------------------------------

  function updatePlaybackToggle() {
    if (togglePause) togglePause.classList.toggle('active', settings.pauseOnSheetOpen);
    if (toggleKeep) toggleKeep.classList.toggle('active', !settings.pauseOnSheetOpen);
  }

  // ---------------------------------------------------------------------------
  // Volume icon (three-state)
  // ---------------------------------------------------------------------------

  function updateVolumeIcon() {
    if (!muteBtn) return;
    var isMuted = video.muted || video.volume === 0;
    if (isMuted) muteBtn.innerHTML = SVG_VOLUME_OFF;
    else if (video.volume < 0.5) muteBtn.innerHTML = SVG_VOLUME_LOW;
    else muteBtn.innerHTML = SVG_VOLUME_ON;
    muteBtn.setAttribute('aria-label', isMuted ? 'Unmute' : 'Mute');
  }

  // ---------------------------------------------------------------------------
  // Sheet
  // ---------------------------------------------------------------------------

  function openSheet() {
    if (sheetBackdrop) sheetBackdrop.classList.add('active');
    if (sheet) {
      sheet.classList.add('active');
      sheet.setAttribute('aria-hidden', 'false');
    }
    lastFocused = document.activeElement;
    // Matches Swift handleVideoTap(): if "Pause on Open" is on, pause on
    // open. (syncVideo on close re-syncs + resumes when the setting is on.)
    if (settings.pauseOnSheetOpen && !video.paused) {
      video.pause();
    }
    sheetOpen = true;
    clearTimeout(cursorTimer);
    document.body.classList.add('mouse-active');
    document.body.style.cursor = 'default';
    if (closeSheetBtn) closeSheetBtn.focus();
  }

  function closeSheet() {
    if (sheetBackdrop) sheetBackdrop.classList.remove('active');
    if (sheet) {
      sheet.classList.remove('active');
      sheet.setAttribute('aria-hidden', 'true');
    }
    sheetOpen = false;
    if (lastFocused && typeof lastFocused.focus === 'function') lastFocused.focus();

    // Matches Swift hideSettings(): when "Pause on Open" is on, closing the
    // sheet re-syncs and resumes — regardless of how playback was paused
    // (space bar, toggle button, or the sheet itself).
    if (settings.pauseOnSheetOpen && video.paused) {
      video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);
      video.play().catch(function () {});
    }

    if (!hasPlayedOnce) {
      video.muted = false;
      updateVolumeIcon();
      if (unmuteHint) unmuteHint.style.opacity = '0';
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
    // Respect users who asked the OS to reduce motion: keep the cursor
    // visible instead of auto-hiding it on a timer.
    if (!reducedMotion) cursorTimer = setTimeout(hideCursor, CURSOR_HIDE_DELAY_MS);
  }

  function hideCursor() {
    if (sheetOpen) return;
    document.body.classList.remove('mouse-active');
    document.body.style.cursor = 'none';
  }

  // ---------------------------------------------------------------------------
  // Mute / Volume / Fullscreen
  // ---------------------------------------------------------------------------

  function toggleMute() {
    video.muted = !video.muted;
    updateVolumeIcon();
  }

  function syncFullscreenIcon() {
    if (!fullscreenBtn) return;
    fullscreenBtn.innerHTML = isFullscreen ? SVG_MINIMIZE : SVG_MAXIMIZE;
    fullscreenBtn.setAttribute('aria-label', isFullscreen ? 'Exit fullscreen' : 'Enter fullscreen');
  }

  function toggleFullscreen() {
    // Serialize rapid presses: while one toggle's IPC round-trip is in flight,
    // ignore further presses so a double-press can't read stale state and
    // collapse into a single (or contradictory) toggle.
    if (fullscreenInFlight) return;
    fullscreenInFlight = true;
    // Query the real window state so we toggle correctly even if the user
    // exited fullscreen via the OS (green traffic light, Cmd+Ctrl+F, etc.).
    invoke('plugin:window|is_fullscreen', { label: 'main' }).then(function (fs) {
      isFullscreen = !fs;
      invoke('plugin:window|set_fullscreen', { label: 'main', fullscreen: isFullscreen }).catch(function () {});
      syncFullscreenIcon();
    }).catch(function () {
      isFullscreen = !isFullscreen;
      invoke('plugin:window|set_fullscreen', { label: 'main', fullscreen: isFullscreen }).catch(function () {});
      syncFullscreenIcon();
    }).finally(function () {
      fullscreenInFlight = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  async function init() {
    initTheme();
    updatePlaybackToggle();

    video.src = convertFileSrc('video.mp4', 'gandalf');

    var ntpResult;
    var metadataPromise = new Promise(function (resolve, reject) {
      video.addEventListener('loadedmetadata', function () { resolve(); }, { once: true });
      video.addEventListener('error', function () {
        reject(new Error('Video load failed: code=' + (video.error ? video.error.code : '?')));
      }, { once: true });
      setTimeout(function () { reject(new Error('Metadata timeout')); }, 10_000);
    });

    var results = await Promise.all([invoke('sync_ntp'), metadataPromise]);
    ntpResult = results[0];

    ntpOffsetMicros = ntpResult.offset_micros;
    durationMicros = Math.round(video.duration * 1_000_000);
    isSynced = ntpResult.is_synced;
    ready = true;

    if (syncDot) syncDot.style.background = isSynced ? '#22c55e' : '#ef4444';
    if (syncLabel) syncLabel.textContent = isSynced ? 'NTP' : 'Sync failed';

    video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);

    try { await video.play(); } catch (e) { console.warn('[gandalf] Autoplay blocked:', e.message); }

    // Unmute on first interaction (but not if clicking inside the sheet)
    function unmute(e) {
      if (e && e.target && sheet && sheet.contains(e.target)) return;
      video.muted = false;
      updateVolumeIcon();
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

  if (videoContainer) videoContainer.addEventListener('click', openSheet);
  if (controls) controls.addEventListener('click', function (e) { e.stopPropagation(); });
  if (sheetBackdrop) sheetBackdrop.addEventListener('click', closeSheet);
  if (closeSheetBtn) closeSheetBtn.addEventListener('click', closeSheet);

  if (togglePause) togglePause.addEventListener('click', function () {
    settings.pauseOnSheetOpen = true;
    localStorage.setItem('gandalf_pause_on_open', 'true');
    updatePlaybackToggle();
    // Matches Swift pauseOnOpenTapped → onPause: always pause.
    if (sheetOpen && !video.paused) { video.pause(); }
  });
  if (toggleKeep) toggleKeep.addEventListener('click', function () {
    settings.pauseOnSheetOpen = false;
    localStorage.setItem('gandalf_pause_on_open', 'false');
    updatePlaybackToggle();
    // Matches Swift keepPlayingTapped → onPlay: always resume (re-synced),
    // even if the pause came from the space bar.
    if (sheetOpen && video.paused) {
      video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);
      video.play().catch(function () {});
    }
  });

  if (themeLight) themeLight.addEventListener('click', function () {
    settings.theme = 'light'; localStorage.setItem('gandalf_theme', 'light'); applyTheme('light');
  });
  if (themeDark) themeDark.addEventListener('click', function () {
    settings.theme = 'dark'; localStorage.setItem('gandalf_theme', 'dark'); applyTheme('dark');
  });
  if (themeSystem) themeSystem.addEventListener('click', function () {
    settings.theme = 'system'; localStorage.setItem('gandalf_theme', 'system'); applyTheme('system');
  });

  if (btnVideo) btnVideo.addEventListener('click', function () {
    invoke('open_url', { url: YOUTUBE_URL }).catch(function () {});
  });

  if (btnShare) btnShare.addEventListener('click', function () {
    invoke('copy_to_clipboard', { text: SHARE_TEXT }).then(function () {
      if (shareFeedback) {
        shareFeedback.classList.add('visible');
        setTimeout(function () { shareFeedback.classList.remove('visible'); }, 2000);
      }
    }).catch(function () {});
  });

  if (sheet) sheet.addEventListener('click', function (e) {
    var link = e.target.closest('a[data-url]');
    if (link) { e.preventDefault(); invoke('open_url', { url: link.dataset.url }).catch(function () {}); }
  });

  if (fullscreenBtn) fullscreenBtn.addEventListener('click', toggleFullscreen);
  if (muteBtn) muteBtn.addEventListener('click', toggleMute);

  if (volumeSlider) volumeSlider.addEventListener('input', function (e) {
    video.volume = parseFloat(e.target.value);
    video.muted = video.volume === 0;
    updateVolumeIcon();
  });

  document.addEventListener('mousemove', function () { if (!sheetOpen) showCursor(); });
  showCursor();

  // Reconcile the fullscreen icon when the OS changes window state on its own
  // (green traffic light, Cmd+Ctrl+F, etc.). Best-effort — never throws.
  var tauriEvent = window.__TAURI__ && window.__TAURI__.event;
  if (tauriEvent && typeof tauriEvent.listen === 'function') {
    try {
      tauriEvent.listen('tauri://resize', function () {
        invoke('plugin:window|is_fullscreen', { label: 'main' }).then(function (fs) {
          isFullscreen = !!fs;
          syncFullscreenIcon();
        }).catch(function () {});
      });
    } catch (e) {}
  }

  // ---------------------------------------------------------------------------
  // Keyboard
  // ---------------------------------------------------------------------------

  document.addEventListener('keydown', function (e) {
    switch (e.code) {
      case 'Space':
        // If a button/input/etc. has focus, let Space activate that control
        // natively instead of toggling the sheet.
        if (e.target instanceof HTMLElement && /^(BUTTON|INPUT|SELECT|TEXTAREA|A)$/.test(e.target.tagName)) return;
        // Space toggles the settings sheet (like clicking the video):
        // open pauses-on-open, close resumes — in "Pause on Open" mode the
        // open/close brackets a pause; in "Keep Playing" mode playback is
        // untouched. Either way, Space never drives playback directly, so it
        // can't desync the sheet's resume logic.
        e.preventDefault();
        if (!ready) return;
        if (sheetOpen) { closeSheet(); } else { openSheet(); }
        break;

      case 'Escape':
        e.preventDefault();
        if (sheetOpen) { closeSheet(); }
        else {
          isFullscreen = false;
          invoke('plugin:window|set_fullscreen', { label: 'main', fullscreen: false }).catch(function () {});
          syncFullscreenIcon();
        }
        break;

      case 'KeyM': toggleMute(); break;
      case 'KeyF': e.preventDefault(); toggleFullscreen(); break;

      case 'ArrowUp':
        // Don't hijack arrow keys while focus is inside the settings sheet.
        if (e.target instanceof HTMLElement && e.target.closest && e.target.closest('#sheet')) break;
        e.preventDefault();
        video.volume = Math.min(1, video.volume + 0.05);
        if (video.volume > 0) video.muted = false;
        if (volumeSlider) volumeSlider.value = video.volume;
        updateVolumeIcon();
        break;

      case 'ArrowDown':
        if (e.target instanceof HTMLElement && e.target.closest && e.target.closest('#sheet')) break;
        e.preventDefault();
        video.volume = Math.max(0, video.volume - 0.05);
        video.muted = video.volume === 0;
        if (volumeSlider) volumeSlider.value = video.volume;
        updateVolumeIcon();
        break;
    }
  });

  // ---------------------------------------------------------------------------
  // Boot
  // ---------------------------------------------------------------------------

  init().catch(function (e) {
    console.error('[gandalf]', e);
    // ready never becomes true on failure, so the app appears frozen. Surface
    // the failure in the DOM — a packaged Tauri webview has no console.
    if (syncLabel) syncLabel.textContent = 'Video failed to load — restart the app.';
    if (syncDot) syncDot.style.background = '#ef4444';
    if (unmuteHint) {
      unmuteHint.textContent = 'Load failed — restart the app';
      unmuteHint.style.opacity = '1';
    }
  });

})();
