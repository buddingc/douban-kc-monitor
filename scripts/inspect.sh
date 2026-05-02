#!/usr/bin/env bash
set -uo pipefail

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
TIMESTAMP=$(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M')

curl -s --max-time 30 -A "$UA" "https://www.douban.com/group/656297/?tab=42899" -o /tmp/douban_kc.html
CURL_EXIT=$?
KC_COUNT=$(grep -c '【开车】' /tmp/douban_kc.html 2>/dev/null || echo 0)
HTML_LINES=$(wc -l < /tmp/douban_kc.html 2>/dev/null || echo 0)

{
  echo "豆瓣【开车】巡检 ${TIMESTAMP}"
  echo ""
  if [ "$CURL_EXIT" -ne 0 ] || [ "$KC_COUNT" -eq 0 ] || [ "$HTML_LINES" -lt 100 ]; then
    echo "⚠️ 抓取异常 curl_exit=${CURL_EXIT} html_lines=${HTML_LINES} kc_count=${KC_COUNT}"
  else
    grep -oE 'href="https://www\.douban\.com/group/topic/[0-9]+/[^"]*"[^>]*title="【开车】[^"]+"' /tmp/douban_kc.html \
      | head -15 \
      | sed -E 's|.*topic/([0-9]+)/[^"]*"[^>]*title="(【开车】[^"]+)".*|- \2\nhttps://www.douban.com/group/topic/\1/|'
  fi
} > /tmp/douban_msg.txt

cat /tmp/douban_msg.txt
echo ""
echo "=== telegram response ==="

curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
  -d "chat_id=${TG_CHAT_ID}" \
  --data-urlencode "text@/tmp/douban_msg.txt" \
  -d "disable_web_page_preview=true"
echo ""
