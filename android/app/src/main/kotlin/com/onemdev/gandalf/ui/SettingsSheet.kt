package com.onemdev.gandalf.ui

import android.content.Intent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import com.onemdev.gandalf.analytics.Analytics
import com.onemdev.gandalf.player.SyncSource
import com.onemdev.gandalf.theme.AppSettings
import com.onemdev.gandalf.theme.ThemeMode

private const val YOUTUBE_LINK = "https://youtu.be/BBGEG21CGo0"
private const val USER = "hmziqrs"

data class SocialLink(
    val label: String,
    val url: String,
    val icon: @Composable () -> Unit,
)

val socialLinks = listOf(
    SocialLink("hmziq.rs", "https://hmziq.rs") {
        Icon(Icons.Filled.Language, contentDescription = null, modifier = Modifier.size(18.dp))
    },
    SocialLink("@$USER", "https://github.com/$USER") {
        Icon(Icons.Filled.Code, contentDescription = null, modifier = Modifier.size(18.dp))
    },
    SocialLink(USER, "https://x.com/$USER") {
        Icon(Icons.Filled.Close, contentDescription = null, modifier = Modifier.size(18.dp))
    },
    SocialLink(USER, "https://t.me/$USER") {
        Icon(Icons.Filled.Send, contentDescription = null, modifier = Modifier.size(18.dp))
    },
)

@Composable
fun SettingsSheet(
    settings: AppSettings,
    syncSource: SyncSource,
    onThemeChange: (ThemeMode) -> Unit,
    onBackgroundPlaybackChange: (Boolean) -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val uriHandler = LocalUriHandler.current
    val padding = 16.dp

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = padding, vertical = padding),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        // Sync status indicator
        SyncStatusChip(syncSource)

        Spacer(modifier = Modifier.height(8.dp))

        // Header
        Text(
            text = "Behold the glory of infinite Gandalf!",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
        )
        Text(
            text = "Billions must be entertained!",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.primary,
        )

        Spacer(modifier = Modifier.height(8.dp))

        // Theme selection
        Text(
            text = "Theme",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.SemiBold,
        )
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth(),
        ) {
            ThemeButton("Light", Icons.Filled.LightMode, ThemeMode.LIGHT, settings.themeMode, onThemeChange)
            ThemeButton("Dark", Icons.Filled.DarkMode, ThemeMode.DARK, settings.themeMode, onThemeChange)
            ThemeButton("System", Icons.Filled.SettingsBrightness, ThemeMode.SYSTEM, settings.themeMode, onThemeChange)
        }

        Spacer(modifier = Modifier.height(4.dp))

        // Background playback toggle
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text(
                text = "Background Playback",
                style = MaterialTheme.typography.titleSmall,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.weight(1f),
            )
            Switch(
                checked = settings.backgroundPlayback,
                onCheckedChange = {
                    onBackgroundPlaybackChange(it)
                    Analytics.logToggleBackgroundPlayback(it)
                },
            )
        }

        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

        // Developer info
        Text(
            text = "Developer: $USER",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.SemiBold,
        )
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            socialLinks.forEach { link ->
                FilledTonalIconButton(onClick = {
                    Analytics.logClickSocialLink(link.label, link.url)
                    uriHandler.openUri(link.url)
                }) {
                    link.icon()
                }
            }
        }

        Spacer(modifier = Modifier.height(4.dp))

        // Video source
        Text(
            text = "Video source:",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.SemiBold,
        )
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            OutlinedButton(
                onClick = { uriHandler.openUri(YOUTUBE_LINK) },
                shape = RoundedCornerShape(12.dp),
            ) {
                Icon(Icons.Filled.PlayCircleFilled, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(4.dp))
                Text("Original video")
            }
            OutlinedButton(
                onClick = {
                    Analytics.logShareContent()
                    val shareIntent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, "Check out Epic Sax Gandalf: $YOUTUBE_LINK")
                        putExtra(Intent.EXTRA_SUBJECT, "Epic Sax Gandalf")
                    }
                    context.startActivity(Intent.createChooser(shareIntent, "Share via"))
                },
                shape = RoundedCornerShape(12.dp),
            ) {
                Icon(Icons.Filled.Share, contentDescription = null, modifier = Modifier.size(18.dp))
            }
        }

        Spacer(modifier = Modifier.height(16.dp))
    }
}

@Composable
private fun RowScope.ThemeButton(
    label: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    mode: ThemeMode,
    currentMode: ThemeMode,
    onThemeChange: (ThemeMode) -> Unit,
) {
    val isSelected = currentMode == mode
    FilledTonalButton(
        onClick = {
            onThemeChange(mode)
            Analytics.logChangeTheme(mode.name.lowercase())
        },
        modifier = Modifier.weight(1f),
        shape = RoundedCornerShape(12.dp),
        colors = if (isSelected) {
            ButtonDefaults.filledTonalButtonColors(
                containerColor = MaterialTheme.colorScheme.primary,
                contentColor = MaterialTheme.colorScheme.onPrimary,
            )
        } else {
            ButtonDefaults.filledTonalButtonColors()
        },
    ) {
        Icon(icon, contentDescription = null, modifier = Modifier.size(18.dp))
        Spacer(modifier = Modifier.width(4.dp))
        Text(label)
    }
}

@Composable
private fun SyncStatusChip(syncSource: SyncSource) {
    val (text, color) = when (syncSource) {
        SyncSource.NTP -> "NTP synced" to MaterialTheme.colorScheme.primary
        SyncSource.DEVICE_CLOCK -> "Device time" to MaterialTheme.colorScheme.outline
    }
    AssistChip(
        onClick = {},
        label = { Text(text, style = MaterialTheme.typography.labelSmall) },
        leadingIcon = {
            Icon(
                Icons.Filled.Sync,
                contentDescription = null,
                modifier = Modifier.size(16.dp),
                tint = color,
            )
        },
    )
}
