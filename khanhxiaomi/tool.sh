#!/bin/bash

VERSION="4.68"
BASE_URL="https://raw.githubusercontent.com/yourname/tvtool/main"

# ===== CHỐNG DEBUG =====
[[ "$-" == *x* ]] && exit

# ===== CHECK KEY =====
check_key() {
  echo "🔐 NHẬP KEY:"
  read -p "👉 KEY: " USER_KEY

  DEVICE=$(getprop ro.serialno 2>/dev/null || hostname)

  DATA=$(curl -s $BASE_URL/keys.txt)

  LINE=$(echo "$DATA" | grep "^$USER_KEY|")

  [ -z "$LINE" ] && {
    echo "❌ KEY SAI"
    exit
  }

  STATUS=$(echo "$LINE" | cut -d'|' -f2)
  KEY_DEVICE=$(echo "$LINE" | cut -d'|' -f3)

  if [[ "$STATUS" != "active" ]]; then
    echo "❌ KEY BỊ KHÓA"
    exit
  fi

  if [[ -n "$KEY_DEVICE" && "$KEY_DEVICE" != "$DEVICE" ]]; then
    echo "❌ KEY KHÁC THIẾT BỊ"
    exit
  fi

  echo "✅ KEY OK"
}

# ===== UPDATE =====
check_update() {
  NEW=$(curl -s $BASE_URL/version.txt)

  if [[ "$NEW" != "$VERSION" ]]; then
    echo "🚀 UPDATE..."

    curl -s -o "$0" $BASE_URL/tool.sh
    chmod +x "$0"

    echo "✅ UPDATE XONG"
    exit
  fi
}

# ===== LOAD CORE =====
load_core() {
  echo "📡 LOAD DATA..."

  curl -s $BASE_URL/core.txt | base64 -d | bash
}

# ===== RUN =====
check_key
check_update
load_core