package com.onemdev.gandalf.ui

import android.content.Intent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Brush
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Code
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Language
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.material.icons.filled.PlayCircleFilled
import androidx.compose.material.icons.filled.SettingsBrightness
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.FilledTonalIconButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

import com.onemdev.gandalf.analytics.Analytics
import com.onemdev.gandalf.player.SyncSource
import com.onemdev.gandalf.theme.AppSettings
import com.onemdev.gandalf.theme.ThemeMode

private const val YOUTUBE_LINK = "https://youtu.be/BBGEG21CGo0"

@Composable
fun SettingsSheet(
    settings: AppSettings,
    syncSource: SyncSource,
    onThemeChange: (ThemeMode) -> Unit,
    onPauseOnOpenChange: (Boolean) -> Unit,
    onClose: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val uriHandler = LocalUriHandler.current

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(start = 24.dp, end = 24.dp, top = 20.dp, bottom = 24.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        // 1. Close button row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.End,
        ) {
            IconButton(onClick = onClose) {
                Icon(
                    imageVector = Icons.Filled.Close,
                    contentDescription = "Close",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }

        // 2. Header
        Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
            Text(
                text = "Behold the glory of infinite Gandalf!",
                fontWeight = FontWeight.Bold,
                fontSize = 17.sp,
            )
            Text(
                text = "Billions must be entertained!",
                color = MaterialTheme.colorScheme.error,
                fontWeight = FontWeight.Medium,
                fontSize = 11.sp,
            )
        }

        // 3. Sync status
        Row(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier = Modifier
                    .size(8.dp)
                    .clip(CircleShape)
                    .background(
                        when (syncSource) {
                            SyncSource.NTP -> Color(0xFF4CAF50) // Green
                            SyncSource.DEVICE_CLOCK -> Color.Gray
                        }
                    ),
            )
            Text(
                text = when (syncSource) {
                    SyncSource.NTP -> "NTP Synced"
                    SyncSource.DEVICE_CLOCK -> "Device Time"
                },
                fontSize = 11.sp,
                fontWeight = FontWeight.Medium,
            )
        }

        // 4. Divider
        HorizontalDivider()

        // 5. Playback section
        SectionHeader(title = "Playback", icon = Icons.Filled.PlayCircleFilled)
        Row(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            modifier = Modifier.fillMaxWidth(),
        ) {
            // Pause on Open button
            val pauseSelected = settings.pauseOnOpen
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(34.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(
                        if (pauseSelected) MaterialTheme.colorScheme.primaryContainer
                        else MaterialTheme.colorScheme.surfaceVariant
                    )
                    .clickable {
                        onPauseOnOpenChange(true)
                        Analytics.logTogglePauseOnOpen(true)
                    },
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = "Pause on Open",
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 12.sp,
                    textAlign = TextAlign.Center,
                    color = if (pauseSelected) MaterialTheme.colorScheme.onPrimary
                    else MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            // Keep Playing button
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(34.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(
                        if (!pauseSelected) MaterialTheme.colorScheme.primaryContainer
                        else MaterialTheme.colorScheme.surfaceVariant
                    )
                    .clickable {
                        onPauseOnOpenChange(false)
                        Analytics.logTogglePauseOnOpen(false)
                    },
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = "Keep Playing",
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 12.sp,
                    textAlign = TextAlign.Center,
                    color = if (!pauseSelected) MaterialTheme.colorScheme.onPrimary
                    else MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }

        // 6. Divider
        HorizontalDivider()

        // 7. Appearance section
        SectionHeader(title = "Appearance", icon = Icons.Filled.Brush)
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth(),
        ) {
            ThemeButton("Light", Icons.Filled.LightMode, ThemeMode.LIGHT, settings.themeMode, onThemeChange)
            ThemeButton("Dark", Icons.Filled.DarkMode, ThemeMode.DARK, settings.themeMode, onThemeChange)
            ThemeButton("System", Icons.Filled.SettingsBrightness, ThemeMode.SYSTEM, settings.themeMode, onThemeChange)
        }

        // 8. Divider
        HorizontalDivider()

        // 9. Developer section
        SectionHeader(title = "Developer", icon = Icons.Filled.Code)
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Text(
                text = "Built by ",
                fontSize = 11.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Text(
                text = "hmziqrs",
                fontSize = 11.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.primary,
            )
            Spacer(modifier = Modifier.weight(1f))
            FilledTonalIconButton(
                onClick = {
                    Analytics.logClickSocialLink("hmziq.rs", "https://hmziq.rs")
                    uriHandler.openUri("https://hmziq.rs")
                },
            ) {
                Icon(
                    Icons.Filled.Language,
                    contentDescription = "hmziq.rs",
                    modifier = Modifier.size(16.dp),
                )
            }
            FilledTonalIconButton(
                onClick = {
                    Analytics.logClickSocialLink("hmziq.xyz", "https://hmziq.xyz")
                    uriHandler.openUri("https://hmziq.xyz")
                },
            ) {
                Icon(
                    Icons.Filled.Language,
                    contentDescription = "hmziq.xyz",
                    modifier = Modifier.size(16.dp),
                )
            }
            FilledTonalIconButton(
                onClick = {
                    Analytics.logClickSocialLink("github", "https://github.com/hmziqrs")
                    uriHandler.openUri("https://github.com/hmziqrs")
                },
            ) {
                Icon(
                    Icons.Filled.Code,
                    contentDescription = "GitHub",
                    modifier = Modifier.size(16.dp),
                )
            }
            FilledTonalIconButton(
                onClick = {
                    Analytics.logClickSocialLink("x.com", "https://x.com/hmziqrs")
                    uriHandler.openUri("https://x.com/hmziqrs")
                },
            ) {
                Icon(
                    Icons.Filled.Close,
                    contentDescription = "X",
                    modifier = Modifier.size(16.dp),
                )
            }
        }

        // 10. Divider
        HorizontalDivider()

        // 11. Video section
        SectionHeader(title = "Video", icon = Icons.Filled.PlayCircleFilled)
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            OutlinedButton(
                onClick = { uriHandler.openUri(YOUTUBE_LINK) },
                shape = RoundedCornerShape(12.dp),
            ) {
                Icon(
                    Icons.Filled.PlayCircleFilled,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp),
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text("Original Video")
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
                Icon(
                    Icons.Filled.Share,
                    contentDescription = "Share",
                    modifier = Modifier.size(18.dp),
                )
            }
        }
    }
}

@Composable
private fun SectionHeader(title: String, icon: ImageVector) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(14.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Text(
            text = title,
            fontWeight = FontWeight.SemiBold,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}

@Composable
private fun RowScope.ThemeButton(
    label: String,
    icon: ImageVector,
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
            androidx.compose.material3.ButtonDefaults.filledTonalButtonColors(
                containerColor = MaterialTheme.colorScheme.primary,
                contentColor = MaterialTheme.colorScheme.onPrimary,
            )
        } else {
            androidx.compose.material3.ButtonDefaults.filledTonalButtonColors(
                containerColor = MaterialTheme.colorScheme.surfaceVariant,
                contentColor = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        },
    ) {
        Icon(icon, contentDescription = null, modifier = Modifier.size(18.dp))
        Spacer(modifier = Modifier.width(4.dp))
        Text(label)
    }
}
