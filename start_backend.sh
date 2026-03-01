#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# TruthLens — Backend Starter + IP Auto-Updater
# Run this script once whenever you start working:
#   chmod +x start_backend.sh   (first time only)
#   ./start_backend.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e

BACKEND_DIR="$(cd "$(dirname "$0")/apps/backend" && pwd)"
CONSTANTS_FILE="$(cd "$(dirname "$0")/apps/frontend/lib/core/services" && pwd)/api_constants.dart"

# ── 1. Detect current LAN IP ─────────────────────────────────────────────────
detect_ip() {
  # Try en0 (Wi-Fi), then en1, then any active non-loopback interface
  for iface in en0 en1 en2 wlan0 eth0; do
    ip=$(ipconfig getifaddr "$iface" 2>/dev/null)
    if [ -n "$ip" ]; then
      echo "$ip"
      return
    fi
  done
  # Fallback: parse ifconfig
  ifconfig | awk '/inet / && !/127\.0\.0\.1/ { print $2; exit }'
}

IP=$(detect_ip)

if [ -z "$IP" ]; then
  echo "❌  Could not detect LAN IP. Are you connected to Wi-Fi?"
  exit 1
fi

echo "✅  Detected IP: $IP"

# ── 2. Update api_constants.dart ─────────────────────────────────────────────
if [ ! -f "$CONSTANTS_FILE" ]; then
  echo "❌  Could not find: $CONSTANTS_FILE"
  exit 1
fi

# Replace the kBaseUrl line regardless of what IP was there before
sed -i '' "s|const String kBaseUrl = 'http://[^']*';|const String kBaseUrl = 'http://${IP}:8000/api';|" "$CONSTANTS_FILE"

echo "✅  Updated api_constants.dart → http://${IP}:8000/api"

# ── 3. Kill any existing artisan serve ───────────────────────────────────────
pkill -f "artisan serve" 2>/dev/null && echo "🔄  Stopped old server" || true
sleep 1

# ── 4. Start backend bound to 0.0.0.0 ────────────────────────────────────────
cd "$BACKEND_DIR"
nohup php artisan serve --host=0.0.0.0 --port=8000 > /tmp/laravel.log 2>&1 &
SERVER_PID=$!
sleep 2

# ── 5. Verify server is up ────────────────────────────────────────────────────
if curl -s --max-time 3 "http://${IP}:8000/api/login" -X POST \
    -H "Accept: application/json" | grep -q "email\|token\|error\|message"; then
  echo "✅  Server running at http://${IP}:8000"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  📱  Hot-restart your Flutter app and you're done!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "⚠️   Server started (PID $SERVER_PID) but health check inconclusive."
  echo "    Check logs: tail -f /tmp/laravel.log"
fi
