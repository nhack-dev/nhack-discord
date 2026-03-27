#!/bin/bash
# push.sh — バージョンチェック付きgit push
# server.tsを変更したのにplugin.jsonのバージョンを上げてない場合、pushをブロックする

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# server.tsに変更があるか確認
if git diff --cached --name-only | grep -q "server.ts"; then
  # plugin.jsonも同時に変更されてるか確認
  if ! git diff --cached --name-only | grep -q "plugin.json"; then
    echo "❌ エラー: server.tsを変更したのにplugin.jsonのバージョンが更新されていません！"
    echo ""
    echo "   .claude-plugin/plugin.json の version を上げてから再度コミットしてください"
    echo "   例: 1.0.0 → 1.0.1（バグ修正）/ 1.1.0（機能追加）/ 2.0.0（大きな変更）"
    echo ""
    echo "   バージョンを上げないとクライアントに更新が届きません！"
    exit 1
  fi
fi

# チェック通過 → push実行
git push "$@"
echo "✅ push完了！"
