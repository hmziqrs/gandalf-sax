package com.onemdev.gandalf.ntp

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.withContext
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import kotlin.math.roundToLong

/**
 * NTP client that queries multiple servers and returns a median offset
 * between device time and true NTP time.
 *
 * Usage:
 *   val client = NtpClient()
 *   val offsetMicros = client.sync()
 *   val correctedTimeMicros = deviceTimeMicros + offsetMicros
 */
class NtpClient {

    companion object {
        private const val TAG = "NtpClient"
        private const val NTP_PORT = 123
        private const val NTP_PACKET_SIZE = 48
        private const val TIMEOUT_MS = 3000L

        // Seconds between 1900-01-01 and 1970-01-01
        private const val SECONDS_1900_TO_1970 = 2208988800L

        private val NTP_SERVERS = listOf(
            "time.google.com",
            "time.cloudflare.com",
            "time.apple.com",
            "pool.ntp.org",
        )
    }

    /** Offset in microseconds: ntpTime - deviceTime */
    var offsetMicros: Long = 0
        private set

    /** Whether we have a valid NTP offset from a successful sync */
    var isSynced: Boolean = false
        private set

    /**
     * Query NTP servers and compute the median offset.
     * Returns the offset in microseconds (ntpTime - deviceTime).
     * Falls back to previous offset if fewer than 2 servers respond.
     */
    suspend fun sync(): Long = withContext(Dispatchers.IO) {
        try {
            coroutineScope {
                val results = NTP_SERVERS.map { server ->
                    async { queryServer(server) }
                }.mapNotNull { it.await() }

                if (results.size < 2) {
                    Log.w(TAG, "Only ${results.size}/${NTP_SERVERS.size} NTP servers responded, keeping previous offset")
                    return@withContext offsetMicros
                }

                val sorted = results.sorted()
                val median = sorted[sorted.size / 2]

                offsetMicros = median
                isSynced = true
                Log.d(TAG, "NTP sync complete: offset=${offsetMicros}µs (${"%.2f".format(offsetMicros / 1000.0)}ms)")
                offsetMicros
            }
        } catch (e: Exception) {
            Log.e(TAG, "NTP sync failed", e)
            offsetMicros
        }
    }

    /**
     * Query a single NTP server.
     *
     * NTP offset formula: offset = ((T2 - T1) + (T3 - T4)) / 2
     *   T1 = client send time, T2 = server receive time
     *   T3 = server transmit time, T4 = client receive time
     *
     * Returns offset in microseconds, or null on failure.
     */
    private fun queryServer(host: String): Long? {
        val socket = DatagramSocket()
        return try {
            socket.soTimeout = TIMEOUT_MS.toInt()

            val buffer = ByteArray(NTP_PACKET_SIZE)
            // First byte: LI=0 (0), VN=4 (4<<3=32), Mode=3 (client) => 0+32+3 = 35 = 0x23
            buffer[0] = 0x23

            // Write client transmit time at bytes 40-47 (T1)
            val t1Nanos = System.nanoTime()
            val t1Millis = System.currentTimeMillis()
            writeTimestamp(buffer, 40, t1Millis)

            val address = InetAddress.getByName(host)
            socket.send(DatagramPacket(buffer, buffer.size, address, NTP_PORT))

            // Receive response
            val response = ByteArray(NTP_PACKET_SIZE)
            socket.receive(DatagramPacket(response, response.size))

            val t4Millis = System.currentTimeMillis()

            // Parse server timestamps
            val t2Millis = readTimestamp(response, 32)
            val t3Millis = readTimestamp(response, 40)

            // offset = ((T2 - T1) + (T3 - T4)) / 2
            val offsetMs = ((t2Millis - t1Millis) + (t3Millis - t4Millis)) / 2.0
            val offsetMicros = (offsetMs * 1000.0).roundToLong()

            Log.d(TAG, "NTP $host: offset=${"%.2f".format(offsetMs)}ms")
            offsetMicros
        } catch (e: Exception) {
            Log.d(TAG, "NTP query failed for $host: ${e.message}")
            null
        } finally {
            socket.close()
        }
    }

    /**
     * Write a Unix epoch milliseconds timestamp as an NTP 64-bit timestamp
     * at the given offset in the buffer.
     */
    private fun writeTimestamp(buf: ByteArray, offset: Int, millis: Long) {
        val seconds = millis / 1000 + SECONDS_1900_TO_1970
        val fraction = ((millis % 1000 + 1000) % 1000) * 4294967296L / 1000

        // Write seconds (big-endian, 4 bytes)
        buf[offset] = (seconds ushr 24).toByte()
        buf[offset + 1] = (seconds ushr 16).toByte()
        buf[offset + 2] = (seconds ushr 8).toByte()
        buf[offset + 3] = seconds.toByte()

        // Write fraction (big-endian, 4 bytes)
        buf[offset + 4] = (fraction ushr 24).toByte()
        buf[offset + 5] = (fraction ushr 16).toByte()
        buf[offset + 6] = (fraction ushr 8).toByte()
        buf[offset + 7] = fraction.toByte()
    }

    /**
     * Read an NTP 64-bit timestamp from the buffer and return milliseconds
     * since Unix epoch.
     */
    private fun readTimestamp(buf: ByteArray, offset: Int): Long {
        val seconds = ((buf[offset].toLong() and 0xFF) shl 24) or
                ((buf[offset + 1].toLong() and 0xFF) shl 16) or
                ((buf[offset + 2].toLong() and 0xFF) shl 8) or
                (buf[offset + 3].toLong() and 0xFF)

        val fraction = ((buf[offset + 4].toLong() and 0xFF) shl 24) or
                ((buf[offset + 5].toLong() and 0xFF) shl 16) or
                ((buf[offset + 6].toLong() and 0xFF) shl 8) or
                (buf[offset + 7].toLong() and 0xFF)

        val unixSeconds = seconds - SECONDS_1900_TO_1970
        val millis = fraction * 1000 / 4294967296L
        return unixSeconds * 1000 + millis
    }
}
