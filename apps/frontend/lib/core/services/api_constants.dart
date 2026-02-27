/// Shared backend base URL.
/// Uses the Mac's LAN IP so real Android/iOS devices on the same Wi-Fi can reach it.
/// Update this if the Mac's IP changes (run: ipconfig getifaddr en0).
const String kBaseUrl = 'http://192.168.1.220:8000/api';
