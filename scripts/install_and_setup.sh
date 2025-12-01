#!/usr/bin/env bash
# install_and_setup.sh
# Install prerequisites guidance, install npm deps, build project (if applicable),
# and optionally generate SSL certs.
set -euo pipefail

SKIP_SSL=0
CNF=""
FORCE_SSL=0
NO_NPM=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-ssl) SKIP_SSL=1; shift;;
    --cnf) CNF="$2"; shift 2;;
    --force-ssl) FORCE_SSL=1; shift;;
    --no-npm) NO_NPM=1; shift;;
    -h|--help) echo "Usage: $0 [--skip-ssl] [--cnf ssl/distinguished.cnf] [--force-ssl] [--no-npm]"; exit 0;;
    *) echo "Unknown arg $1"; exit 2;;
  esac
done

echo "Starting install_and_setup..."

if ! command -v node >/dev/null 2>&1; then
  echo "node not found."
  echo "Please install Node.js (LTS). On Debian/Ubuntu: sudo apt-get install -y nodejs npm"
  exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl not found. Please install openssl (e.g. sudo apt-get install -y openssl) and re-run."
  exit 1
fi

if [[ $NO_NPM -eq 0 && -f package.json ]]; then
  echo "Installing npm dependencies..."
  npm install
else
  echo "Skipping npm install."
fi

if [[ $NO_NPM -eq 0 && -f package.json ]]; then
  if npm run | grep -q "build"; then
    echo "Running npm run build..."
    npm run build || echo "Build script failed or not present."
  fi
fi

if [[ $SKIP_SSL -eq 0 ]]; then
  CNF_ARG=()
  if [[ -n "$CNF" ]]; then
    CNF_ARG=(--cnf "$CNF")
  fi
  FORCE_ARG=()
  if [[ $FORCE_SSL -eq 1 ]]; then
    FORCE_ARG=(--force)
  fi
  echo "Generating SSL certs..."
  bash ./scripts/generate_ssl.sh --out-dir ssl "${CNF_ARG[@]}" "${FORCE_ARG[@]}" || {
    echo "SSL generation failed."
    exit 1
  }
else
  echo "Skipping SSL generation as requested."
fi

echo "Installation and setup complete."
echo "To run the HTTPS dashboard:"
echo "  ./scripts/start_dashboard.sh --port 8000 --open"
