# ImmortalWrt 自动编译

使用 GitHub Actions 自动编译 [ImmortalWrt](https://github.com/immortalwrt/immortalwrt) 固件

## 项目结构

```
.
├── .github/workflows/
│   └── build.yml              # 编译工作流
├── Devices/                   # 设备目录（每个设备一个文件夹）
│   └── Cudy TR3000/
│       ├── device.yaml        # 设备参数（型号、固件目录、TARGET）
│       ├── packages.yaml      # 软件包配置（启用/禁用）
│       ├── packages.sh        # 自定义软件包脚本（克隆外部仓库）
│       └── customize.sh       # 设备定制脚本（修改 DTS 等）
├── README.md
└── .gitignore
```

## 使用方法

1. Fork 本仓库
2. 进入 **Actions** -> **Build ImmortalWrt**
3. 选择设备和版本 -> 点击 **Run workflow**
4. 等待编译完成（约 2-4 小时）
5. 在 Actions 页面 **Artifacts** 下载固件

## 工作流参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `device` | 目标设备 | `Cudy TR3000` |
| `tag` | ImmortalWrt 版本标签 | `latest` |
| `disk_cleanup` | 启用磁盘空间清理 | `false` |
| `skip_compile` | 跳过编译（调试模式） | `false` |

## 编译流程

```
阶段 1: 系统环境初始化
  [1.1] 系统信息
  [1.2] 磁盘空间清理（可选）
  [1.3] 克隆配置仓库
  [1.4] 加载设备配置

阶段 2: 源码准备
  [2.1] 安装编译环境
  [2.2] 确定版本标签
  [2.3] 克隆 ImmortalWrt 源码
  [2.4] 更新 feeds
  [2.5] 安装 feeds

阶段 3: 自定义固件
  [3.1] 添加自定义软件包（packages.sh）
  [3.2] 设备定制（customize.sh）
  [3.3] 生成编译配置（packages.yaml）
  [3.4] 同步配置（make defconfig）
  [3.5] 修复 Rust LLVM

阶段 4: 编译固件
  [4.1] 预下载资源
  [4.2] 编译固件
  [4.3] 编译后磁盘使用

阶段 5: 上传固件
  [5.1] 整理固件
  [5.2] 上传 squashfs-sysupgrade
  [5.3] 上传 initramfs-recovery
  [5.4] 上传配置文件
```

## 配置文件说明

### device.yaml

设备配置文件，定义设备的基本参数：

```yaml
# 设备型号（用于固件命名）
model: "Cudy TR3000"

# 自定义软件包列表文件
packages_list: "packages.yaml"

# 设备 TARGET（用于 make defconfig）
target: "CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000-v1-ubootmod=y"
```

### packages.yaml

软件包配置文件，管理启用和禁用的包：

```yaml
# 启用的包
enable:
  - luci-i18n-base-zh-cn
  - luci-theme-argon
  - luci-app-mwan3
  - luci-app-ttyd
  - luci-app-openclash
  - kmod-mtd-rw

# 禁用的包（本体）
disable:
  - luci-app-passwall
  - luci-app-rclone

# 禁用的子组件
disable_components:
  luci-app-passwall:
    - INCLUDE_Haproxy
    - INCLUDE_SingBox
    - INCLUDE_Xray
```

### packages.sh

克隆外部仓库的脚本（从 GitHub 获取最新版本）：

```bash
#!/bin/bash
set -e

OPENWRT_DIR="$(pwd)"

# 删除 feeds 旧版本，克隆到 package/app/
find "$OPENWRT_DIR/package/feeds/" -name "luci-app-openclash" -exec rm -rf {} + 2>/dev/null
git clone --depth 1 https://github.com/vernesong/OpenClash.git \
    "$OPENWRT_DIR/package/app/OpenClash"
echo "[OK] 已添加: OpenClash"
```

### customize.sh

设备定制脚本（修改 DTS、内核配置等）：

```bash
#!/bin/bash
set -e

# 修改设备型号名称
DTS_FILE="target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1-ubootmod.dts"
if [ -f "$DTS_FILE" ]; then
    sed -i 's/Cudy TR3000 v1 (OpenWrt U-Boot layout)/Cudy TR3000/g' "$DTS_FILE"
fi
```

## 添加新设备

以 `NanoPi R4S` 为例：

### 1. 创建设备目录

```bash
mkdir -p "Devices/NanoPi R4S"
```

### 2. 创建 device.yaml

```yaml
model: "NanoPi R4S"
packages_list: "packages.yaml"
target: "CONFIG_TARGET_rockchip_armv8_DEVICE_friendlyarm_nanopi-r4s=y"
```

### 3. 创建 packages.yaml

```yaml
enable:
  - luci-i18n-base-zh-cn
  - luci-app-mwan3
  - luci-app-ttyd

disable:
  - luci-app-passwall
```

### 4. 编写 packages.sh（可选）

```bash
#!/bin/bash
set -e
OPENWRT_DIR="$(pwd)"

git clone --depth 1 https://github.com/vernesong/OpenClash.git \
    "$OPENWRT_DIR/package/app/OpenClash"
```

### 5. 编写 customize.sh（可选）

```bash
#!/bin/bash
set -e

DTS_FILE="target/linux/rockchip/dts/rk3399-nanopi-r4s.dts"
if [ -f "$DTS_FILE" ]; then
    sed -i 's/FriendlyARM NanoPi R4S/NanoPi R4S/g' "$DTS_FILE"
fi
```

### 6. 注册设备

编辑 `.github/workflows/build.yml`，在 `device` 的 `options` 中添加：

```yaml
device:
  type: choice
  options:
    - "Cudy TR3000"
    - "NanoPi R4S"
```

## 已支持设备

| 设备 | TARGET | 状态 |
|------|--------|------|
| Cudy TR3000 | `CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000-v1-ubootmod=y` | 支持 |

## 输出文件

编译完成后会上传 4 个 Artifact：

| 文件 | 说明 |
|------|------|
| `ImmortalWrt-设备-版本-sysupgrade.zip` | 系统升级固件 |
| `ImmortalWrt-设备-版本-recovery.zip` | 恢复/工厂固件 |
| `ImmortalWrt-设备-版本-config.zip` | 编译配置文件 |
| `ImmortalWrt-设备-版本-full.zip` | 完整固件包（包含以上所有） |

支持的固件格式：`.itb`、`.bin`、`.img.gz`、`.squashfs`

## 许可证

[MIT](LICENSE)
