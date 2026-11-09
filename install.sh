#!/usr/bin/env bash
#
# scnet installer (binary release):
#   curl -fsSL https://raw.githubusercontent.com/lql341/scnet-tui/main/install.sh | bash
#
# Downloads the prebuilt single-file binary for this platform. The source code
# is not distributed through this installer.
set -euo pipefail

RELEASE_BASE="${SCNET_RELEASE_BASE:-https://github.com/lql341/scnet-tui/releases/latest/download}"
VERSION_URL="${SCNET_VERSION_URL:-https://raw.githubusercontent.com/lql341/scnet-tui/main/version.txt}"
INSTALL_DIR="${SCNET_INSTALL_DIR:-$HOME/.local/share/scnet}"
BIN_DIR="${SCNET_BIN_DIR:-$HOME/.local/bin}"
VERSION="${SCNET_VERSION:-}"

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
  *) echo "unsupported OS: $os" >&2; exit 1 ;;
esac
case "$arch" in
  x86_64|amd64) cpu=x64 ;;
  aarch64|arm64) cpu=arm64 ;;
  *) echo "unsupported architecture: $arch" >&2; exit 1 ;;
esac

if [ -z "$VERSION" ]; then
  VERSION=$(curl -fsSL "$VERSION_URL" 2>/dev/null | tr -d '[:space:]') || true
fi
if [ -z "$VERSION" ]; then
  echo "could not determine the latest version; set SCNET_VERSION" >&2
  exit 1
fi

name="scnet-$VERSION-$platform-$cpu"
url="${RELEASE_BASE%/}/$name.tar.gz"
echo "downloading $url ..."
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp/$name.tar.gz"
if curl -fsSL "${url}.sha256" -o "$tmp/checksum.txt" 2>/dev/null; then
  expected=$(awk '{print $1}' "$tmp/checksum.txt" | head -1)
  if command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$tmp/$name.tar.gz" | awk '{print $1}')
  else
    actual=$(shasum -a 256 "$tmp/$name.tar.gz" | awk '{print $1}')
  fi
  if [ -n "$expected" ] && [ "$expected" != "$actual" ]; then
    echo "checksum mismatch: expected $expected, got $actual" >&2
    exit 1
  fi
  echo "checksum ok"
fi

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
tar -xzf "$tmp/$name.tar.gz" -C "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/scnet"
mkdir -p "$BIN_DIR"
ln -sfn "$INSTALL_DIR/scnet" "$BIN_DIR/scnet"

echo
echo "installed: $BIN_DIR/scnet"
echo "add to PATH if needed: export PATH=\"$BIN_DIR:\$PATH\""
echo "next: scnet doctor && scnet login"
