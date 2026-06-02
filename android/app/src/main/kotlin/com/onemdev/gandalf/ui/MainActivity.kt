package com.onemdev.gandalf.ui

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
import androidx.compose.ui.viewinterop.AndroidView
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

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val settingsRepo = remember { SettingsRepository(dataStore) }
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
    val context = LocalContext.current

    var showSheet by remember { mutableStateOf(false) }

    // Create player once
    val player = remember {
        viewModel.createPlayer(context)
    }

    // Log screen view on first composition
    LaunchedEffect(Unit) {
        Analytics.logViewHomeScreen()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
            .pointerInput(Unit) {
                detectTapGestures {
                    viewModel.pause()
                    Analytics.logOpenSheet()
                    showSheet = true
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

        // Settings bottom sheet
        if (showSheet) {
            ModalBottomSheet(
                onDismissRequest = {
                    showSheet = false
                    viewModel.syncVideo()
                },
                containerColor = MaterialTheme.colorScheme.surface,
            ) {
                SettingsSheet(
                    settings = settings,
                    syncSource = videoState.syncSource,
                    onThemeChange = { mode ->
                        onThemeChange(mode)
                        onSettingsRepo().setThemeMode(mode)
                    },
                    onBackgroundPlaybackChange = { enabled ->
                        onSettingsRepo().setBackgroundPlayback(enabled)
                    },
                )
            }
        }
    }
}
