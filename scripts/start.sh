#!/bin/bash
# start.sh — バイナリ優先、フォールバックでbun実行
DATA_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/channels/discord}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# バイナリがあればバイナリ実行
if [ -f "$DATA_DIR/nhack-discord" ]; then
  exec "$DATA_DIR/nhack-discord"
fi

# Windowsバイナリチェック
if [ -f "$DATA_DIR/nhack-discord.exe" ]; then
  exec "$DATA_DIR/nhack-discord.exe"
fi

# フォールバック: bun実行
exec bun run --cwd "$PLUGIN_ROOT" start
