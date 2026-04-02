#!/bin/bash
# push.sh — バージョンチェック付きgit push
# server.tsを変更したのにplugin.jsonのバージョンを上げてない場合、pushをブロックする

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 最新コミットのserver.tsが前コミットから変更されてるか確認
CHANGED_FILES=$(git diff HEAD~1 --name-only 2>/dev/null || echo "")

if echo "$CHANGED_FILES" | grep -q "server.ts"; then
  # plugin.jsonのバージョンが前コミットから変わってるか確認
  CURRENT_VER=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])" 2>/dev/null)
  PREV_VER=$(git show HEAD~1:.claude-plugin/plugin.json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['version'])" 2>/dev/null || echo "0.0.0")

  if [ "$CURRENT_VER" = "$PREV_VER" ]; then
    echo "❌ エラー: server.tsを変更したのにplugin.jsonのバージョンが更新されていません！"
    echo ""
    echo "   現在: $CURRENT_VER"
    echo "   .claude-plugin/plugin.json の version を上げてから再度コミットしてください"
    echo "   例: $CURRENT_VER → $(echo $CURRENT_VER | awk -F. '{print $1"."$2"."$3+1}')（パッチ）"
    echo ""
    echo "   バージョンを上げないとクライアントに更新が届きません！"
    exit 1
  fi

  echo "✅ バージョンチェック通過: $PREV_VER → $CURRENT_VER"
fi

# チェック通過 → push実行
git push "$@"
echo "✅ push完了！"
