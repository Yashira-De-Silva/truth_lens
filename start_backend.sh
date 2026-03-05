#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# TruthLens — Backend + ML Service Starter + IP Auto-Updater
# Run this script once whenever you start working:
#   chmod +x start_backend.sh   (first time only)
#   ./start_backend.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e

BACKEND_DIR="$(cd "$(dirname "$0")/apps/backend" && pwd)"
ML_DIR="$(cd "$(dirname "$0")/apps/ml_service" && pwd)"
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

# Replace the kBaseUrl line
sed -i '' "s|const String kBaseUrl      = 'http://[^']*';|const String kBaseUrl      = 'http://${IP}:8000/api';|" "$CONSTANTS_FILE"
# Replace the kMlServiceUrl line
sed -i '' "s|const String kMlServiceUrl = 'http://[^']*';|const String kMlServiceUrl = 'http://${IP}:5001';|" "$CONSTANTS_FILE"

echo "✅  Updated api_constants.dart → Laravel: http://${IP}:8000/api | ML: http://${IP}:5000"

# ── 3. Kill any existing artisan serve ───────────────────────────────────────
pkill -f "artisan serve" 2>/dev/null && echo "🔄  Stopped old Laravel server" || true
sleep 1

# ── 4. Start Laravel backend bound to 0.0.0.0 ────────────────────────────────
cd "$BACKEND_DIR"
nohup php artisan serve --host=0.0.0.0 --port=8000 > /tmp/laravel.log 2>&1 &
echo "✅  Laravel server starting on port 8000 …"

# ── 5. Kill any existing ML service ──────────────────────────────────────────
pkill -f "app.py" 2>/dev/null && echo "🔄  Stopped old ML service" || true
sleep 1

# ── 6. Start Python ML service ───────────────────────────────────────────────
cd "$ML_DIR"
nohup python3 app.py > /tmp/ml_service.log 2>&1 &
ML_PID=$!
echo "✅  ML service starting (PID $ML_PID) on port 5000 …"
echo "    (First run downloads dataset + trains model — may take a few minutes)"
echo "    Check logs: tail -f /tmp/ml_service.log"

sleep 2

# ── 7. Verify Laravel is up ──────────────────────────────────────────────────
if curl -s --max-time 3 "http://${IP}:8000/api/login" -X POST \
    -H "Accept: application/json" | grep -q "email\|token\|error\|message"; then
  echo "✅  Laravel running at http://${IP}:8000"
else
  echo "⚠️   Laravel health check inconclusive — check: tail -f /tmp/laravel.log"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱  Hot-restart your Flutter app and you're done!"
echo "  🤖  ML service logs: tail -f /tmp/ml_service.log"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
