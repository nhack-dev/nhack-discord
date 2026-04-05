#!/bin/bash
# start.sh — バイナリ実行のみ（ソースコードはプライベートリポに移動済み）
# NOTE: PreToolUseフック・Playwright MCPのセットアップはオンボーディングで案内
#       settings.jsonへの自動書き込みは凛の環境を壊すリスクがあるため廃止
DATA_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/channels/discord}"

# バイナリがあればバイナリ実行
if [ -f "$DATA_DIR/nhack-discord" ]; then
  exec "$DATA_DIR/nhack-discord"
fi

# Windowsバイナリチェック
if [ -f "$DATA_DIR/nhack-discord.exe" ]; then
  exec "$DATA_DIR/nhack-discord.exe"
fi

# バイナリがない場合はセットアップを実行
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
if [ -f "$PLUGIN_ROOT/scripts/setup.sh" ]; then
  bash "$PLUGIN_ROOT/scripts/setup.sh"
  if [ -f "$DATA_DIR/nhack-discord" ]; then
    exec "$DATA_DIR/nhack-discord"
  fi
  if [ -f "$DATA_DIR/nhack-discord.exe" ]; then
    exec "$DATA_DIR/nhack-discord.exe"
  fi
fi

echo "[nhack-discord] Binary not found. Please run: claude plugin update nhack-discord@nhack-plugins" >&2
exit 1
