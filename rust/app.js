(function () {
  'use strict';

  // --- Constants ---
  var BUFFER_FIRST_SYNC_SECS = 0.165;
  var CURSOR_HIDE_DELAY_MS = 3000;
  var DURATION_MICROS = 117_540_000;
  var YOUTUBE_URL = 'https://www.youtube.com/watch?v=gy1B3agGNxw';
  var SHARE_TEXT = 'Epic Sax Gandalf — NTP-synced video loop https://github.com/hmziqrs/gandalf-sax';

  // --- SVG icon templates ---
  var SVG_VOLUME_ON = '<svg class="icon" viewBox="0 0 24 24"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/></svg>';
  var SVG_VOLUME_OFF = '<svg class="icon" viewBox="0 0 24 24"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><line x1="23" y1="9" x2="17" y2="15"/><line x1="17" y1="9" x2="23" y2="15"/></svg>';
  var SVG_MAXIMIZE = '<svg class="icon" viewBox="0 0 24 24"><polyline points="15 3 21 3 21 9"/><polyline points="9 21 3 21 3 15"/><line x1="21" y1="3" x2="14" y2="10"/><line x1="3" y1="21" x2="10" y2="14"/></svg>';
  var SVG_MINIMIZE = '<svg class="icon" viewBox="0 0 24 24"><polyline points="4 14 10 14 10 20"/><polyline points="20 10 14 10 14 4"/><line x1="14" y1="10" x2="21" y2="3"/><line x1="3" y1="21" x2="10" y2="14"/></svg>';

  // --- State ---
  var ntpOffsetMicros = 0;
  var isSynced = false;
  var isPaused = false;
  var sheetOpen = false;
  var hasPlayedOnce = false;
  var isFullscreen = false;
  var cursorTimer = null;

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
    var deviceMicros = Date.now() * 1000;
    var corrected = deviceMicros + ntpOffsetMicros;
    var raw = (corrected % DURATION_MICROS) + (bufferSecs * 1_000_000);
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
      ? (systemDarkQuery.matches ? 'dark' : 'light') : mode);

    if (systemThemeHandler) {
      systemDarkQuery.removeEventListener('change', systemThemeHandler);
      systemThemeHandler = null;
    }
    if (mode === 'system') {
      systemThemeHandler = function (e) {
        document.documentElement.setAttribute('data-theme', e.matches ? 'dark' : 'light');
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
  // Sheet
  // ---------------------------------------------------------------------------

  function openSheet() {
    if (sheetBackdrop) sheetBackdrop.classList.add('active');
    if (sheet) sheet.classList.add('active');
    if (settings.pauseOnSheetOpen) video.pause();
    sheetOpen = true;
    clearTimeout(cursorTimer);
    document.body.classList.add('mouse-active');
    document.body.style.cursor = 'default';
  }

  function closeSheet() {
    if (sheetBackdrop) sheetBackdrop.classList.remove('active');
    if (sheet) sheet.classList.remove('active');
    sheetOpen = false;

    if (!isPaused) {
      video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);
      video.play().catch(function () {});
    }

    if (!hasPlayedOnce) {
      video.muted = false;
      if (muteBtn) muteBtn.innerHTML = SVG_VOLUME_ON;
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
    cursorTimer = setTimeout(hideCursor, CURSOR_HIDE_DELAY_MS);
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
    if (muteBtn) muteBtn.innerHTML = video.muted ? SVG_VOLUME_OFF : SVG_VOLUME_ON;
  }

  function toggleFullscreen() {
    isFullscreen = !isFullscreen;
    invoke('plugin:window|set_fullscreen', { label: 'main', fullscreen: isFullscreen }).catch(function () {});
    if (fullscreenBtn) fullscreenBtn.innerHTML = isFullscreen ? SVG_MINIMIZE : SVG_MAXIMIZE;
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
    isSynced = true;

    if (syncDot) syncDot.style.background = '#22c55e';
    if (syncLabel) syncLabel.textContent = 'NTP';

    video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);

    try { await video.play(); } catch (e) { console.warn('[gandalf] Autoplay blocked:', e.message); }

    // Unmute on first interaction
    function unmute() {
      video.muted = false;
      if (muteBtn) muteBtn.innerHTML = SVG_VOLUME_ON;
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
  });
  if (toggleKeep) toggleKeep.addEventListener('click', function () {
    settings.pauseOnSheetOpen = false;
    localStorage.setItem('gandalf_pause_on_open', 'false');
    updatePlaybackToggle();
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
    navigator.clipboard.writeText(SHARE_TEXT).then(function () {
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
    if (muteBtn) muteBtn.innerHTML = video.muted ? SVG_VOLUME_OFF : SVG_VOLUME_ON;
  });

  document.addEventListener('mousemove', function () { if (!sheetOpen) showCursor(); });
  showCursor();

  // ---------------------------------------------------------------------------
  // Keyboard
  // ---------------------------------------------------------------------------

  document.addEventListener('keydown', async function (e) {
    switch (e.code) {
      case 'Space':
        e.preventDefault();
        if (sheetOpen) return;
        if (isPaused) {
          video.currentTime = calcSeekSecs(BUFFER_FIRST_SYNC_SECS);
          await video.play().catch(function () {});
          isPaused = false;
        } else { video.pause(); isPaused = true; }
        break;

      case 'Escape':
        e.preventDefault();
        if (sheetOpen) { closeSheet(); }
        else {
          isFullscreen = false;
          invoke('plugin:window|set_fullscreen', { label: 'main', fullscreen: false }).catch(function () {});
          if (fullscreenBtn) fullscreenBtn.innerHTML = SVG_MAXIMIZE;
        }
        break;

      case 'KeyM': toggleMute(); break;
      case 'KeyF': e.preventDefault(); toggleFullscreen(); break;

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

  init().catch(function (e) { console.error('[gandalf]', e); });

})();
