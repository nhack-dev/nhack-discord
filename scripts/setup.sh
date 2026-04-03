#!/bin/bash
# setup.sh — プラットフォーム自動検出+バイナリダウンロード
# SessionStartフックから呼ばれる。初回のみダウンロード、以後はバージョンチェックのみ
set -euo pipefail

DATA_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/channels/discord}"
BINARY="$DATA_DIR/nhack-discord"
VERSION_FILE="$DATA_DIR/.binary-version"

# plugin.jsonからバージョン取得
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
REQUIRED_VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "unknown")

# 既にインストール済みで正しいバージョンならスキップ
if [ -f "$BINARY" ] && [ -f "$VERSION_FILE" ] && [ "$(cat "$VERSION_FILE")" = "$REQUIRED_VERSION" ]; then
  exit 0
fi

# プラットフォーム検出
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="x64" ;;
  aarch64|arm64) ARCH="arm64" ;;
esac

EXT=""
case "$OS" in
  darwin) PLATFORM="darwin-${ARCH}" ;;
  linux) PLATFORM="linux-${ARCH}" ;;
  mingw*|msys*|cygwin*) PLATFORM="windows-x64"; EXT=".exe"; BINARY="${BINARY}.exe" ;;
  *) echo "[nhack-discord] Unsupported platform: $OS" >&2; exit 0 ;;
esac

# GitHub Releasesからダウンロード
REPO="nhack-dev/nhack-discord"
ASSET="nhack-discord-${PLATFORM}${EXT}"
URL="https://github.com/${REPO}/releases/download/v${REQUIRED_VERSION}/${ASSET}"

mkdir -p "$DATA_DIR"
echo "[nhack-discord] Downloading binary v${REQUIRED_VERSION} for ${PLATFORM}..." >&2

if curl -fsSL "$URL" -o "$BINARY" 2>/dev/null; then
  chmod +x "$BINARY"
  echo "$REQUIRED_VERSION" > "$VERSION_FILE"
  echo "[nhack-discord] Binary installed: v${REQUIRED_VERSION}" >&2
else
  echo "[nhack-discord] Binary download failed (${URL}). Falling back to bun." >&2
  rm -f "$BINARY" "$VERSION_FILE"
  exit 0
fi
