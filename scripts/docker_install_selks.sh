#!/usr/bin/env bash
# docker_install_selks.sh
# Generate SSL certs (if missing) and bring up Docker stack with nginx TLS proxy + dashboard.
set -euo pipefail

CNF=""
FORCE_SSL=0
DO_BUILD=0
DETACH=0

print_usage() {
  cat <<EOF
Usage: $0 [--cnf ssl/distinguished.cnf] [--force-ssl] [--build] [--detach]

--cnf         Use the provided OpenSSL config for certificate generation.
--force-ssl   Overwrite existing ssl/private-key.pem and ssl/certificate.pem.
--build       Force docker-compose build before starting.
--detach      Run docker-compose up -d (default is foreground).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cnf) CNF="$2"; shift 2;;
    --force-ssl) FORCE_SSL=1; shift;;
    --build) DO_BUILD=1; shift;;
    --detach) DETACH=1; shift;;
    -h|--help) print_usage; exit 0;;
    *) echo "Unknown arg $1"; print_usage; exit 2;;
  esac
done

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DOCKER_DIR="${ROOT_DIR}/docker"
SSL_DIR="${ROOT_DIR}/ssl"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found. Please install Docker: https://docs.docker.com/get-docker/"
  exit 1
fi

if ! command -v docker-compose >/dev/null 2>&1; then
  echo "docker-compose not found. Please install docker-compose (or use docker compose) and re-run."
  exit 2
fi

mkdir -p "$SSL_DIR"
KEY_FILE="${SSL_DIR}/private-key.pem"
CRT_FILE="${SSL_DIR}/certificate.pem"

if [[ -f "$KEY_FILE" && -f "$CRT_FILE" && $FORCE_SSL -eq 0 ]]; then
  echo "SSL certs already exist in ${SSL_DIR}."
else
  echo "Generating self-signed SSL certs into ${SSL_DIR}..."
  if [[ -x "${ROOT_DIR}/scripts/generate_ssl.sh" ]]; then
    ARGS=(--out-dir "$SSL_DIR")
    if [[ -n "$CNF" ]]; then ARGS+=(--cnf "$CNF"); fi
    if [[ $FORCE_SSL -eq 1 ]]; then ARGS+=(--force); fi
    bash "${ROOT_DIR}/scripts/generate_ssl.sh" "${ARGS[@]}"
  else
    if ! command -v openssl >/dev/null 2>&1; then
      echo "openssl not available to create certs. Install openssl or provide certs in ${SSL_DIR}."
      exit 3
    fi
    openssl req -nodes -new -x509 -keyout "${KEY_FILE}" -out "${CRT_FILE}" -days 365 -subj "/CN=localhost"
    chmod 600 "${KEY_FILE}"
  fi
fi

pushd "$DOCKER_DIR" >/dev/null
if [[ $DO_BUILD -eq 1 ]]; then
  docker-compose build
fi

if [[ $DETACH -eq 1 ]]; then
  docker-compose up -d
else
  docker-compose up
fi
popd >/dev/null
