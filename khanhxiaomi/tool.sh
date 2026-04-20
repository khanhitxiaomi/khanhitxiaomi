#!/bin/bash

VERSION="4.68"
BASE_URL="https://raw.githubusercontent.com/khanhitxiaomi/khanhitxiaomi/main/khanhxiaomi"

# ===== CHỐNG DEBUG =====
[[ "$-" == *x* ]] && exit

# ===== CHECK KEY =====
check_key() {
  read -p "🔐 Nhập key: " USER_KEY

  DEVICE=$(getprop ro.serialno 2>/dev/null || hostname)

  DATA=$(curl -s $BASE_URL/keys.txt)

  LINE=$(echo "$DATA" | grep "^$USER_KEY|")

  [ -z "$LINE" ] && {
    echo "❌ KEY SAI"
    exit
  }

  STATUS=$(echo "$LINE" | cut -d'|' -f2)
  KEY_DEVICE=$(echo "$LINE" | cut -d'|' -f3)

  [[ "$STATUS" != "active" ]] && {
    echo "❌ KEY BỊ KHÓA"
    exit
  }

  if [[ -n "$KEY_DEVICE" && "$KEY_DEVICE" != "$DEVICE" ]]; then
    echo "❌ KHÁC THIẾT BỊ"
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

    echo "✅ XONG → MỞ LẠI"
    exit
  fi
}

# ===== LOAD CORE =====
load_core() {
  TMP="/tmp/core.txt"

  curl -s $BASE_URL/core.txt -o $TMP

  [ ! -s "$TMP" ] && exit

  base64 -d $TMP | base64 -d | bash
}

# ===== RUN =====
check_key
check_update
load_core
