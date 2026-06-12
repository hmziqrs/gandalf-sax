use std::net::UdpSocket;
use std::time::Duration;
use log::{debug, info, warn};

const NTP_PORT: u16 = 123;
const NTP_PACKET_SIZE: usize = 48;
const TIMEOUT: Duration = Duration::from_secs(3);

/// Seconds between 1900-01-01 and 1970-01-01
const SECONDS_1900_TO_1970: u64 = 2_208_988_800;

const NTP_SERVERS: &[&str] = &[
    "time.google.com",
    "time.cloudflare.com",
    "time.apple.com",
    "pool.ntp.org",
];

/// NTP client state
pub struct NtpClient {
    /// Offset in microseconds: ntpTime - deviceTime
    pub offset_micros: i64,
    pub is_synced: bool,
}

impl NtpClient {
    pub fn new() -> Self {
        Self {
            offset_micros: 0,
            is_synced: false,
        }
    }

    /// Query NTP servers and compute the median offset.
    /// Returns the offset in microseconds.
    pub fn sync(&mut self) -> i64 {
        let mut offsets: Vec<i64> = Vec::new();

        for server in NTP_SERVERS {
            if let Some(offset) = Self::query_server(server) {
                debug!("NTP {}: offset={:.2}ms", server, offset as f64 / 1000.0);
                offsets.push(offset);
            }
        }

        if offsets.len() < 2 {
            warn!(
                "Only {}/{} NTP servers responded, keeping previous offset",
                offsets.len(),
                NTP_SERVERS.len()
            );
            return self.offset_micros;
        }

        offsets.sort();
        let median = offsets[offsets.len() / 2];

        self.offset_micros = median;
        self.is_synced = true;
        info!(
            "NTP sync complete: offset={:.2}ms",
            median as f64 / 1000.0
        );

        median
    }

    /// Query a single NTP server. Returns offset in microseconds, or None on failure.
    ///
    /// NTP offset: offset = ((T2 - T1) + (T3 - T4)) / 2
    fn query_server(host: &str) -> Option<i64> {
        let socket = UdpSocket::bind("0.0.0.0:0").ok()?;
        socket.set_read_timeout(Some(TIMEOUT)).ok()?;
        socket.connect((host, NTP_PORT)).ok()?;

        let mut packet = [0u8; NTP_PACKET_SIZE];
        // LI=0, VN=4, Mode=3 (client) => 0x23
        packet[0] = 0x23;

        // Write client transmit timestamp at bytes 40-47 (T1)
        let t1_millis = Self::millis_since_epoch();
        Self::write_timestamp(&mut packet, 40, t1_millis);

        socket.send(&packet).ok()?;

        let mut response = [0u8; NTP_PACKET_SIZE];
        socket.recv(&mut response).ok()?;

        let t4_millis = Self::millis_since_epoch();

        let t2_millis = Self::read_timestamp(&response, 32);
        let t3_millis = Self::read_timestamp(&response, 40);

        // offset = ((T2 - T1) + (T3 - T4)) / 2
        let offset_ms = ((t2_millis as f64 - t1_millis as f64)
            + (t3_millis as f64 - t4_millis as f64))
            / 2.0;
        let offset_micros = (offset_ms * 1000.0) as i64;

        Some(offset_micros)
    }

    /// Current time in milliseconds since Unix epoch
    fn millis_since_epoch() -> u64 {
        use std::time::SystemTime;
        SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap()
            .as_millis() as u64
    }

    fn write_timestamp(buf: &mut [u8], offset: usize, millis: u64) {
        let seconds = millis / 1000 + SECONDS_1900_TO_1970;
        let fraction = (millis % 1000) * 4_294_967_296 / 1000;

        buf[offset] = (seconds >> 24) as u8;
        buf[offset + 1] = (seconds >> 16) as u8;
        buf[offset + 2] = (seconds >> 8) as u8;
        buf[offset + 3] = seconds as u8;
        buf[offset + 4] = (fraction >> 24) as u8;
        buf[offset + 5] = (fraction >> 16) as u8;
        buf[offset + 6] = (fraction >> 8) as u8;
        buf[offset + 7] = fraction as u8;
    }

    fn read_timestamp(buf: &[u8], offset: usize) -> u64 {
        let seconds = ((buf[offset] as u64) << 24)
            | ((buf[offset + 1] as u64) << 16)
            | ((buf[offset + 2] as u64) << 8)
            | (buf[offset + 3] as u64);

        let fraction = ((buf[offset + 4] as u64) << 24)
            | ((buf[offset + 5] as u64) << 16)
            | ((buf[offset + 6] as u64) << 8)
            | (buf[offset + 7] as u64);

        let unix_seconds = seconds - SECONDS_1900_TO_1970;
        let millis = fraction * 1000 / 4_294_967_296;
        unix_seconds * 1000 + millis
    }
}
