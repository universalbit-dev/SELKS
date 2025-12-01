#!/usr/bin/env bash
# generate_ssl.sh
# Generate self-signed SSL certs for development.
# Usage:
#   ./scripts/generate_ssl.sh [--days DAYS] [--out-dir DIR] [--cnf PATH] [--hostname HOSTNAME] [--force]
set -euo pipefail

DAYS=365
OUT_DIR="ssl"
CNF=""
HOSTNAME="localhost"
FORCE=0

print_usage() {
  cat <<EOF
Usage: $0 [--days DAYS] [--out-dir DIR] [--cnf PATH] [--hostname HOSTNAME] [--force]

--days      Number of days the cert is valid (default: ${DAYS})
--out-dir   Output directory to write private-key.pem and certificate.pem (default: ${OUT_DIR})
--cnf       Use existing OpenSSL config file (e.g. ssl/distinguished.cnf)
--hostname  Common Name for certificate (default: ${HOSTNAME})
--force     Overwrite existing files without prompting
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --days) DAYS="$2"; shift 2;;
    --out-dir) OUT_DIR="$2"; shift 2;;
    --cnf) CNF="$2"; shift 2;;
    --hostname) HOSTNAME="$2"; shift 2;;
    --force) FORCE=1; shift;;
    -h|--help) print_usage; exit 0;;
    *) echo "Unknown arg: $1"; print_usage; exit 2;;
  esac
done

mkdir -p "$OUT_DIR"

KEY_FILE="${OUT_DIR}/private-key.pem"
CRT_FILE="${OUT_DIR}/certificate.pem"

if [[ -e "$KEY_FILE" || -e "$CRT_FILE" ]]; then
  if [[ $FORCE -ne 1 ]]; then
    echo "One of $KEY_FILE or $CRT_FILE already exists. Use --force to overwrite."
    exit 1
  else
    echo "Overwriting existing keys in $OUT_DIR"
  fi
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl not found in PATH. Please install openssl and retry."
  exit 2
fi

if [[ -n "$CNF" ]]; then
  echo "Generating self-signed certificate using config: $CNF"
  openssl req -nodes -new -x509 \
    -keyout "$KEY_FILE" -out "$CRT_FILE" -days "$DAYS" \
    -config "$CNF"
else
  echo "No config provided. Generating recommended self-signed certificate with SANs for localhost."
  TMP_CNF="$(mktemp)"
  cat > "$TMP_CNF" <<EOF
[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
x509_extensions    = v3_req
prompt             = no

[ req_distinguished_name ]
C = US
ST = State
L = City
O = Company
OU = Dev
CN = ${HOSTNAME}

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
DNS.2 = ${HOSTNAME}
IP.1  = 127.0.0.1
EOF

  openssl req -nodes -new -x509 \
    -keyout "$KEY_FILE" -out "$CRT_FILE" -days "$DAYS" \
    -config "$TMP_CNF"
  rm -f "$TMP_CNF"
fi

# Secure the private key
chmod 600 "$KEY_FILE"

echo "Wrote:"
echo "  Key: $KEY_FILE"
echo "  Cert: $CRT_FILE"
echo "Note: Browsers will warn for self-signed certs. Use a CA-signed cert for production."
