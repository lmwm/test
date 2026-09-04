#!/bin/bash
#
# Cudy TR3000 自定义软件包
# 此脚本在 feeds install 之后、make defconfig 之前执行
#
# 用法：在 immortalwrt 源码根目录下执行
#

set -e

OPENWRT_DIR="$(pwd)"

# -----------------------------------------------------------
# luci-theme-argon (最新版)
# 删除 feeds 旧版本，克隆到 package/app/
# -----------------------------------------------------------
find "$OPENWRT_DIR/package/feeds/" -name "luci-theme-argon" -exec rm -rf {} + 2>/dev/null
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git \
    "$OPENWRT_DIR/package/app/luci-theme-argon"
echo "[OK] 已添加: luci-theme-argon"

# -----------------------------------------------------------
# luci-app-argon-config (配套)
# 删除 feeds 旧版本，克隆到 package/app/
# -----------------------------------------------------------
find "$OPENWRT_DIR/package/feeds/" -name "luci-app-argon-config" -exec rm -rf {} + 2>/dev/null
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git \
    "$OPENWRT_DIR/package/app/luci-app-argon-config"
echo "[OK] 已添加: luci-app-argon-config"

# -----------------------------------------------------------
# OpenClash
# 删除 feeds 旧版本，克隆到 package/app/
# -----------------------------------------------------------
find "$OPENWRT_DIR/package/feeds/" -name "luci-app-openclash" -exec rm -rf {} + 2>/dev/null
git clone --depth 1 https://github.com/vernesong/OpenClash.git \
    "$OPENWRT_DIR/package/app/OpenClash"
echo "[OK] 已添加: OpenClash (luci-app-openclash)"

# -----------------------------------------------------------
# OpenAppFilter
# 删除 feeds 旧版本，克隆到 package/app/
# -----------------------------------------------------------
find "$OPENWRT_DIR/package/feeds/" -name "luci-app-oaf" -exec rm -rf {} + 2>/dev/null
git clone --depth 1 https://github.com/destan19/OpenAppFilter.git \
    "$OPENWRT_DIR/package/app/OpenAppFilter"
echo "[OK] 已添加: OpenAppFilter (luci-app-oaf)"

# -----------------------------------------------------------
# luci-app-harbor-file
# 克隆到 package/app/
# -----------------------------------------------------------
git clone --depth 1 https://github.com/destan19/luci-app-harbor-file.git \
    "$OPENWRT_DIR/package/app/luci-app-harbor-file"
echo "[OK] 已添加: luci-app-harbor-file"
