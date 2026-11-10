#!/usr/bin/env bash
#
# scnet installer (prebuilt binary):
#   curl -fsSL https://raw.githubusercontent.com/lql341/scnet-tui/main/install.sh | bash
#
# Resolves the latest release asset, downloads it with resume support, verifies
# sha256 when available, then links ~/.local/bin/scnet.
set -euo pipefail

REPO="${SCNET_REPO:-lql341/scnet-tui}"
API="${SCNET_API:-https://api.github.com/repos/$REPO}"
INSTALL_DIR="${SCNET_INSTALL_DIR:-$HOME/.local/share/scnet}"
BIN_DIR="${SCNET_BIN_DIR:-$HOME/.local/bin}"
VERSION="${SCNET_VERSION:-}"
# Optional token: lifts the anonymous GitHub API rate limit (60/hour).
TOKEN="${SCNET_GITHUB_TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
# Optional static mirror: https://host/path containing version.txt and assets.
MIRROR="${SCNET_RELEASE_BASE:-}"

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing required command: $1" >&2; exit 1; }
}
need curl
need tar

os=$(uname -s)
arch=$(uname -m)
case "$os" in
  Linux) platform=linux ;;
  Darwin) platform=darwin ;;
  *) echo "unsupported OS: $os (supported: Linux, macOS)" >&2; exit 1 ;;
esac
case "$arch" in
  x86_64|amd64) cpu=x64 ;;
  aarch64|arm64) cpu=arm64 ;;
  *) echo "unsupported architecture: $arch" >&2; exit 1 ;;
esac

json_field() {
  # Minimal JSON string/number extractor: json_field <json> <key>
  printf '%s' "$1" | tr -d '\n' | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\{0,1\}\([^\",}]*\)\"\{0,1\}.*/\1/p" | head -1
}


asset_id_for() {
  # asset_id_for <release-json> <asset-name>
  printf '%s' "$1" | tr -d ' \n\t' | sed -n 's/.*"assets":\(\[[^]]*\]\).*/\1/p' | sed 's/},{/}\n{/g' | awk -v want="$2" '
    {
      id=""; nm="";
      if (match($0, /"id":[0-9]+/)) id = substr($0, RSTART+5, RLENGTH-5);
      if (match($0, /"name":"[^"]*"/)) nm = substr($0, RSTART+8, RLENGTH-9);
      if (nm == want && id != "") { print id; exit }
    }'
}

api_curl() {
  if [ -n "$TOKEN" ]; then
    curl -fsSL --retry 3 -H "Authorization: Bearer $TOKEN" "$@"
  else
    curl -fsSL --retry 3 "$@"
  fi
}

release_json() {
  api_curl "$API/releases/tags/v$VERSION" 2>/dev/null
}

# Predictable asset URL: no API call, so no anonymous rate limit.
direct_url() {
  printf 'https://github.com/%s/releases/download/v%s/%s' "$REPO" "$VERSION" "$1"
}

asset_url() {
  # asset_url <asset-name>
  if [ -n "$MIRROR" ]; then
    printf '%s/%s' "${MIRROR%/}" "$1"
    return 0
  fi
  if [ "${SCNET_PREFER_API:-0}" != "1" ]; then
    printf '%s' "$(direct_url "$1")"
    return 0
  fi
  json=$(release_json) || return 1
  id=$(asset_id_for "$json" "$1")
  [ -n "$id" ] || return 1
  printf 'https://api.github.com/repos/%s/releases/assets/%s' "$REPO" "$id"
}

if [ -z "$VERSION" ]; then
  if [ -n "$MIRROR" ]; then
    VERSION=$(curl -fsSL --retry 3 "${MIRROR%/}/version.txt" 2>/dev/null | tr -d '[:space:]') || true
  else
    # Prefer version.txt on the default branch: no API call, no rate limit.
    VERSION=$(curl -fsSL --retry 3 "https://raw.githubusercontent.com/$REPO/main/version.txt" 2>/dev/null | tr -d '[:space:]') || VERSION=''
    if [ -z "$VERSION" ]; then
      release=$(api_curl "$API/releases/latest" 2>/dev/null) || release=''
      VERSION=$(json_field "$release" tag_name | sed 's/^v//')
    fi
  fi
fi
if [ -z "$VERSION" ]; then
  echo "could not determine the latest version." >&2
  echo "  set SCNET_VERSION=<version>, or export GITHUB_TOKEN to lift the API rate limit" >&2
  exit 1
fi


name="scnet-$VERSION-$platform-$cpu.tar.gz"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
dest="$tmp/$name"
# Download with resume; binary releases are large and links can drop.
fetch() {
  url=$1
  attempt=0
  while [ "$attempt" -lt 15 ]; do
    attempt=$((attempt + 1))
    if [ -n "$TOKEN" ]; then
      if curl -fsSL --connect-timeout 20 -H 'Accept: application/octet-stream' -H "Authorization: Bearer $TOKEN" -C - -o "$dest" "$url"; then
        return 0
      fi
    elif curl -fsSL --connect-timeout 20 -H 'Accept: application/octet-stream' -C - -o "$dest" "$url"; then
      return 0
    fi
    size=$(wc -c < "$dest" 2>/dev/null || echo 0)
    echo "download interrupted at ${size} bytes (attempt $attempt); resuming ..." >&2
    sleep 2
  done
  return 1
}

url=$(asset_url "$name") || { echo "could not resolve release asset $name" >&2; exit 1; }
echo "downloading $name ..."
if ! fetch "$url"; then
  echo "direct download failed; retrying through the GitHub API ..." >&2
  SCNET_PREFER_API=1
  url=$(asset_url "$name") || { echo "could not resolve release asset $name" >&2; exit 1; }
  rm -f "$dest"
  fetch "$url" || { echo "download failed" >&2; exit 1; }
fi

sum_url=$(asset_url "$name.sha256" 2>/dev/null || true)
if [ -n "$sum_url" ] && curl -fsSL --retry 3 -H 'Accept: application/octet-stream' -o "$tmp/checksum.txt" "$sum_url" 2>/dev/null; then
  expected=$(awk '{print $1}' "$tmp/checksum.txt" | head -1)
  if command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$dest" | awk '{print $1}')
  else
    actual=$(shasum -a 256 "$dest" | awk '{print $1}')
  fi
  if [ -n "$expected" ] && [ "$expected" != "$actual" ]; then
    echo "checksum mismatch: expected $expected, got $actual" >&2
    exit 1
  fi
  echo "checksum ok"
fi

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
tar -xzf "$dest" -C "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/scnet"
mkdir -p "$BIN_DIR"
ln -sfn "$INSTALL_DIR/scnet" "$BIN_DIR/scnet"

echo
echo "installed: $BIN_DIR/scnet (version $VERSION)"
echo "add to PATH if needed: export PATH=\"$BIN_DIR:\$PATH\""
echo "next: scnet doctor && scnet login"
