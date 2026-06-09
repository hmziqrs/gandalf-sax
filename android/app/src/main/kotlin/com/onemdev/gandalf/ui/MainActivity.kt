package com.onemdev.gandalf.ui

import android.app.Activity
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.media3.ui.PlayerView
import com.onemdev.gandalf.analytics.Analytics
import com.onemdev.gandalf.player.VideoPlayerViewModel
import com.onemdev.gandalf.player.VideoState
import com.onemdev.gandalf.theme.AppSettings
import com.onemdev.gandalf.theme.GandalfTheme
import com.onemdev.gandalf.theme.SettingsRepository
import com.onemdev.gandalf.theme.ThemeMode
import com.onemdev.gandalf.theme.dataStore
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val settingsRepo = remember { SettingsRepository(application.dataStore) }
            val settings by settingsRepo.settings.collectAsStateWithLifecycle(
                initialValue = AppSettings()
            )

            GandalfTheme(themeMode = settings.themeMode) {
                GandalfApp(
                    settings = settings,
                    onThemeChange = { mode ->
                        Analytics.logChangeTheme(mode.name.lowercase())
                    },
                    onSettingsRepo = { settingsRepo },
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GandalfApp(
    settings: AppSettings,
    onThemeChange: (ThemeMode) -> Unit,
    onSettingsRepo: () -> SettingsRepository,
) {
    val viewModel: VideoPlayerViewModel = viewModel()
    val videoState by viewModel.state.collectAsStateWithLifecycle()
    val volume by viewModel.volume.collectAsStateWithLifecycle()
    val context = LocalContext.current
    val view = LocalView.current

    var showSheet by remember { mutableStateOf(false) }
    var showControls by remember { mutableStateOf(false) }
    var isFullscreen by remember { mutableStateOf(false) }

    // Create player once
    val player = remember {
        viewModel.createPlayer(context)
    }

    // Log screen view on first composition
    LaunchedEffect(Unit) {
        Analytics.logViewHomeScreen()
    }

    // Auto-hide controls after 3s
    LaunchedEffect(showControls) {
        if (showControls) {
            delay(3000)
            showControls = false
        }
    }

    // Show controls briefly when sheet closes
    LaunchedEffect(showSheet) {
        if (!showSheet && videoState.isInitialized) {
            showControls = true
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
            .pointerInput(Unit) {
                detectTapGestures {
                    if (showSheet) return@detectTapGestures
                    if (settings.pauseOnOpen) { viewModel.pause() }
                    Analytics.logOpenSheet()
                    showSheet = true
                    showControls = false
                }
            },
        contentAlignment = Alignment.Center,
    ) {
        // Video player
        if (videoState.isInitialized) {
            AndroidView(
                factory = { ctx ->
                    PlayerView(ctx).apply {
                        useController = false
                        this.player = player
                    }
                },
                modifier = Modifier.fillMaxSize(),
            )
        }

        // Controls overlay
        if (videoState.isInitialized && !showSheet) {
            ControlsOverlay(
                volume = volume,
                onVolumeChange = { viewModel.setVolume(it) },
                isFullscreen = isFullscreen,
                onToggleFullscreen = {
                    isFullscreen = !isFullscreen
                    val window = (view.context as Activity).window
                    val controller = WindowCompat.getInsetsController(window, view)
                    if (isFullscreen) {
                        controller.systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
                        controller.hide(WindowInsetsCompat.Type.systemBars())
                    } else {
                        controller.show(WindowInsetsCompat.Type.systemBars())
                    }
                },
                visible = showControls,
                modifier = Modifier.align(Alignment.BottomEnd).padding(16.dp),
            )
        }

        // Settings bottom sheet
        if (showSheet) {
            ModalBottomSheet(
                onDismissRequest = {
                    showSheet = false
                    if (settings.pauseOnOpen) { viewModel.syncVideo() }
                },
                containerColor = MaterialTheme.colorScheme.surface,
            ) {
                SettingsSheet(
                    settings = settings,
                    syncSource = videoState.syncSource,
                    onThemeChange = { mode -> onThemeChange(mode); onSettingsRepo().setThemeMode(mode) },
                    onPauseOnOpenChange = { enabled -> onSettingsRepo().setPauseOnOpen(enabled) },
                    onClose = { showSheet = false; if (settings.pauseOnOpen) viewModel.syncVideo() },
                )
            }
        }
    }
}
