#!/usr/bin/env bash
set -euo pipefail

CERT_FILE="${1:-caddy-root-ca.crt}"

if [[ ! -f "$CERT_FILE" ]]; then
  echo "Zertifikat nicht gefunden: $CERT_FILE" >&2
  exit 1
fi

sudo install -m 0644 "$CERT_FILE" /usr/local/share/ca-certificates/caddy-local-root.crt
sudo update-ca-certificates

echo "Caddy-Root-CA wurde systemweit installiert. Browser und Nextcloud-Client neu starten."
