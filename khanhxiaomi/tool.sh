#!/bin/bash

VERSION="4.68"
BASE_URL="https://raw.githubusercontent.com/khanhitxiaomi/khanhitxiaomi/main/khanhxiaomi"

# ===== BLOCK DEBUG =====
set +x 2>/dev/null

# ===== COLOR =====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

# ===== CHECK KEY =====
check_key() {
  echo -e "${CYAN}🔐 CHECK KEY...${NC}"

  read -p "Nhập key: " USER_KEY

  DEVICE=$(getprop ro.serialno 2>/dev/null || hostname)

  DATA=$(curl -s "$BASE_URL/keys.txt")

  LINE=$(echo "$DATA" | grep "^$USER_KEY|")

  if [ -z "$LINE" ]; then
    echo -e "${RED}❌ KEY SAI${NC}"
    exit 1
  fi

  STATUS=$(echo "$LINE" | cut -d'|' -f2)
  KEY_DEVICE=$(echo "$LINE" | cut -d'|' -f3)

  if [ "$STATUS" != "active" ]; then
    echo -e "${RED}❌ KEY BỊ KHÓA${NC}"
    exit 1
  fi

  if [ -n "$KEY_DEVICE" ] && [ "$KEY_DEVICE" != "$DEVICE" ]; then
    echo -e "${RED}❌ SAI THIẾT BỊ${NC}"
    exit 1
  fi

  echo -e "${GREEN}✅ KEY OK${NC}"
}

# ===== CHECK UPDATE =====
check_update() {
  echo -e "${BLUE}🔄 CHECK UPDATE...${NC}"

  NEW_VERSION=$(curl -s "$BASE_URL/version.txt")

  if [ "$NEW_VERSION" != "$VERSION" ]; then
    echo -e "${YELLOW}🚀 ĐANG UPDATE TOOL...${NC}"

    curl -s -o tool.sh "$BASE_URL/tool.sh"
    chmod +x tool.sh

    echo -e "${GREEN}✅ UPDATE XONG - CHẠY LẠI TOOL${NC}"
    exit 0
  fi
}

# ===== LOAD CORE =====
load_core() {
  echo -e "${CYAN}📦 LOAD CORE...${NC}"

  TMP="/sdcard/Download/core.txt"

  curl -s "$BASE_URL/core.txt" -o "$TMP"

  if [ ! -s "$TMP" ]; then
    echo -e "${RED}❌ LOAD CORE FAIL${NC}"
    exit 1
  fi

  # decode base64 và chạy
  CODE=$(base64 -d "$TMP" 2>/dev/null)

  if [ -z "$CODE" ]; then
    echo -e "${RED}❌ DECODE FAIL${NC}"
    exit 1
  fi

  bash -c "$CODE"
}

# ===== RUN MAIN =====
clear
echo -e "${GREEN}================================"
echo -e "   TOOL XIAOMI TV PRO LOADER"
echo -e "================================${NC}"

check_key
check_update
load_core
