#!/usr/bin/env bash
# start_dashboard.sh
# Start the Node HTTPS server (https_server.js) with generated certs.
set -euo pipefail

PORT=8000
CERT_DIR="ssl"
OPEN_BROWSER=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --port) PORT="$2"; shift 2;;
    --cert-dir) CERT_DIR="$2"; shift 2;;
    --open) OPEN_BROWSER=1; shift;;
    -h|--help) echo "Usage: $0 [--port PORT] [--cert-dir ssl] [--open]"; exit 0;;
    *) echo "Unknown arg $1"; exit 2;;
  esac
done

KEY_FILE="${CERT_DIR}/private-key.pem"
CRT_FILE="${CERT_DIR}/certificate.pem"

if [[ ! -f "$KEY_FILE" || ! -f "$CRT_FILE" ]]; then
  echo "Certs not found in ${CERT_DIR}. Generating now (recommended)..."
  bash ./scripts/generate_ssl.sh --out-dir "$CERT_DIR" || {
    echo "Failed to generate certs."
    exit 1
  }
fi

if [[ ! -f "https_server.js" ]]; then
  echo "https_server.js not found in repository root. Please place your file there (see docs)."
  exit 1
fi

export PORT
echo "Starting HTTPS server on port ${PORT}..."
node https_server.js &

SERVER_PID=$!
sleep 0.5

ps -p $SERVER_PID >/dev/null 2>&1 || {
  echo "Server failed to start. Check https_server.js logs."
  exit 1
}

URL="https://localhost:${PORT}"
echo "HTTPS server started (pid=${SERVER_PID}) at ${URL}"
if [[ $OPEN_BROWSER -eq 1 ]]; then
  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$URL" || true
  elif command -v open >/dev/null 2>&1; then
    open "$URL" || true
  else
    echo "No known browser opener found; open ${URL} manually in your browser."
  fi
fi

echo "To stop the server: kill ${SERVER_PID}"
wait $SERVER_PID
