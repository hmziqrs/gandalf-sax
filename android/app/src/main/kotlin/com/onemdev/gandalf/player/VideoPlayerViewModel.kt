package com.onemdev.gandalf.player

import android.content.Context
import android.net.Uri
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.SeekParameters
import com.onemdev.gandalf.ntp.NtpClient
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

data class VideoState(
    val isInitialized: Boolean = false,
    val isPlaying: Boolean = false,
    val isSynced: Boolean = false,
    val syncSource: SyncSource = SyncSource.DEVICE_CLOCK,
    val durationMicros: Long = 0L,
    val currentPositionMicros: Long = 0L,
)

enum class SyncSource {
    NTP, DEVICE_CLOCK
}

class VideoPlayerViewModel : ViewModel() {

    companion object {
        private const val TAG = "VideoPlayer"
        private const val VIDEO_URI = "asset:///video.mp4"

        // Buffer matching legacy: 25ms base + 140ms on first sync = 165ms
        private const val BUFFER_FIRST_SYNC_MICROS = 165_000L
        private const val BUFFER_MICROS = 25_000L

        // Re-sync every 60 seconds
        private const val RESYNC_INTERVAL_MS = 60_000L
    }

    private val ntpClient = NtpClient()
    private var player: ExoPlayer? = null
    private var isFirstSync = true
    private var resyncJob: Job? = null

    private val _state = MutableStateFlow(VideoState())
    val state: StateFlow<VideoState> = _state.asStateFlow()

    /**
     * Create and configure the ExoPlayer instance.
     * Call this from the Activity/Composable lifecycle.
     */
    fun createPlayer(context: Context): ExoPlayer {
        val exoPlayer = ExoPlayer.Builder(context)
            .setSeekParameters(SeekParameters.EXACT)
            .build()

        exoPlayer.repeatMode = Player.REPEAT_MODE_ONE
        exoPlayer.setMediaItem(MediaItem.fromUri(Uri.parse(VIDEO_URI)))
        exoPlayer.prepare()

        exoPlayer.addListener(object : Player.Listener {
            override fun onPlaybackStateChanged(playbackState: Int) {
                if (playbackState == Player.STATE_READY && !_state.value.isInitialized) {
                    val durationUs = exoPlayer.duration * 1000
                    _state.value = _state.value.copy(
                        isInitialized = true,
                        isPlaying = exoPlayer.isPlaying,
                        durationMicros = durationUs,
                    )
                    // Perform initial NTP sync + seek
                    initialSync(exoPlayer, durationUs)
                }
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                _state.value = _state.value.copy(isPlaying = isPlaying)
            }

            override fun onPlayerError(error: PlaybackException) {
                Log.e(TAG, "Player error", error)
            }
        })

        player = exoPlayer
        return exoPlayer
    }

    /**
     * Initial NTP sync: query servers, compute seek position, seek and play.
     */
    private fun initialSync(exoPlayer: ExoPlayer, durationUs: Long) {
        viewModelScope.launch {
            val offset = ntpClient.sync()
            val buffer = if (isFirstSync) BUFFER_FIRST_SYNC_MICROS else BUFFER_MICROS
            val seekPosition = calculateSeekPosition(offset, durationUs, buffer)

            Log.d(TAG, "Initial sync: offset=${offset}µs, seekTo=${seekPosition}µs (${"%.3f".format(seekPosition / 1_000_000.0)}s)")
            exoPlayer.seekTo(seekPosition / 1000)
            exoPlayer.play()

            _state.value = _state.value.copy(
                isSynced = ntpClient.isSynced,
                syncSource = if (ntpClient.isSynced) SyncSource.NTP else SyncSource.DEVICE_CLOCK,
            )
            isFirstSync = false

            // Start periodic re-sync
            startPeriodicResync()
        }
    }

    /**
     * Re-sync the video to the current global time position.
     * Called when the settings sheet closes and periodically.
     */
    fun syncVideo() {
        val exoPlayer = player ?: return
        val durationUs = _state.value.durationMicros
        if (durationUs == 0L) return

        viewModelScope.launch {
            val offset = ntpClient.offsetMicros
            val buffer = if (isFirstSync) BUFFER_FIRST_SYNC_MICROS else BUFFER_MICROS
            val seekPosition = calculateSeekPosition(offset, durationUs, buffer)

            Log.d(TAG, "Re-sync: seekTo=${seekPosition}µs (${"%.3f".format(seekPosition / 1_000_000.0)}s)")
            exoPlayer.seekTo(seekPosition / 1000)
            exoPlayer.play()

            isFirstSync = false
        }
    }

    /**
     * Full NTP re-sync: query servers again, update offset, then seek.
     */
    private fun fullResync() {
        val exoPlayer = player ?: return
        val durationUs = _state.value.durationMicros
        if (durationUs == 0L) return

        viewModelScope.launch {
            val offset = ntpClient.sync()
            val seekPosition = calculateSeekPosition(offset, durationUs, BUFFER_MICROS)

            Log.d(TAG, "Periodic re-sync: offset=${offset}µs, seekTo=${seekPosition}µs")
            exoPlayer.seekTo(seekPosition / 1000)

            _state.value = _state.value.copy(
                isSynced = ntpClient.isSynced,
                syncSource = if (ntpClient.isSynced) SyncSource.NTP else SyncSource.DEVICE_CLOCK,
            )
        }
    }

    fun pause() {
        player?.pause()
    }

    fun play() {
        player?.play()
    }

    /**
     * Calculate the global-synced seek position.
     *
     * seekPosition = (deviceTimeMicros + ntpOffset) % videoDurationMicros + buffer
     */
    private fun calculateSeekPosition(ntpOffsetMicros: Long, durationUs: Long, buffer: Long): Long {
        val deviceTimeMicros = System.currentTimeMillis() * 1000
        val correctedTime = deviceTimeMicros + ntpOffsetMicros
        return (correctedTime % durationUs) + buffer
    }

    private fun startPeriodicResync() {
        resyncJob?.cancel()
        resyncJob = viewModelScope.launch {
            while (isActive) {
                delay(RESYNC_INTERVAL_MS)
                fullResync()
            }
        }
    }

    override fun onCleared() {
        super.onCleared()
        resyncJob?.cancel()
        player?.release()
        player = null
    }
}
