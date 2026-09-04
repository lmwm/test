# ImmortalWrt 自动编译

使用 GitHub Actions 自动编译 [ImmortalWrt](https://github.com/immortalwrt/immortalwrt) 固件

## 项目结构

```
.
├── .github/workflows/
│   ├── build.yml              # 编译 workflow
│   └── generate-config.yml    # 生成默认配置 workflow
├── Devices/                   # 设备目录（每个设备一个文件夹）
│   └── Cudy TR3000/
│       ├── device.yaml        # 设备参数（型号、固件目录、TARGET）
│       ├── packages.list      # 自定义软件包列表
│       ├── customize.sh       # 设备定制脚本
│       ├── packages.sh        # 自定义软件包脚本（git clone 等）
│       └── files/             # /etc overlay（可选）
├── README.md
└── LICENSE
```

## 使用方法

1. Fork 本仓库
2. 进入 **Actions** -> **Build ImmortalWrt**
3. 选择设备 -> 点击 **Run workflow**
4. 等待编译完成（约 2-4 小时）
5. 在 Actions 页面右上角 **Artifacts** 下载固件

## Workflow 参数

### Build ImmortalWrt

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `device` | 目标设备（下拉选择） | `Cudy TR3000` |
| `tag` | ImmortalWrt 版本标签 | `latest` |
| `disk_cleanup` | 启用磁盘空间清理 | `false` |
| `skip_compile` | 跳过编译（调试模式） | `false` |

### Generate Device Config

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `device` | 目标设备（下拉选择） | `Cudy TR3000` |
| `tag` | ImmortalWrt 版本标签 | `latest` |

## 配置文件说明

### device.yaml

设备配置文件，定义设备的基本参数：

```yaml
# 设备型号（用于固件命名）
model: "Cudy TR3000"

# 固件输出目录（相对于 immortalwrt 源码根目录）
firmware_dir: "bin/targets/mediatek/filogic"

# 自定义软件包列表文件
packages_list: "packages.list"

# 设备 TARGET（用于 make defconfig）
target: "CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000-v1-ubootmod=y"
```

### packages.list

自定义软件包列表，每行一个包名：

```bash
# LuCI 应用
luci-app-firewall
luci-app-mwan3
luci-app-ttyd

# 网络工具
curl
ip-full
etherwake

# 内核模块
kmod-mtd-rw
kmod-tun
```

### packages.sh

用于更复杂的自定义，如 git clone 外部仓库：

```bash
#!/bin/bash
set -e

# 添加 OpenClash
git clone --depth 1 https://github.com/vernesong/OpenClash.git /tmp/OpenClash
cp -rf /tmp/OpenClash/luci-app-openclash "$(pwd)/package/app/"
```

## 添加新设备

以 `NanoPi R4S` 为例：

### 1. 创建设备目录

```bash
mkdir -p "Devices/NanoPi R4S/files"
```

### 2. 创建 device.yaml

编辑 `Devices/NanoPi R4S/device.yaml`：

```yaml
model: "NanoPi R4S"
firmware_dir: "bin/targets/rockchip/armv8"
packages_list: "packages.list"
target: "CONFIG_TARGET_rockchip_armv8_DEVICE_friendlyarm_nanopi-r4s=y"
```

### 3. 创建 packages.list

编辑 `Devices/NanoPi R4S/packages.list`：

```bash
# LuCI 应用
luci-app-firewall
luci-app-mwan3

# 网络工具
curl
etherwake
```

### 4. 编写 customize.sh（可选）

编辑 `Devices/NanoPi R4S/customize.sh`：

```bash
#!/bin/bash
set -e

# 修改 DTS 设备型号
DTS_FILE="target/linux/rockchip/dts/rk3399-nanopi-r4s.dts"
if [ -f "$DTS_FILE" ]; then
    sed -i 's/FriendlyARM NanoPi R4S/FriendlyARM NanoPi R4S Custom/g' "$DTS_FILE"
fi
```

### 5. 放入设备专属 files（可选）

```bash
cp /etc/config/network "Devices/NanoPi R4S/files/etc/config/"
```

### 6. 注册设备

编辑 `.github/workflows/build.yml`，在 `device` 的 `options` 中添加：

```yaml
device:
  type: choice
  options:
    - "Cudy TR3000"
    - "NanoPi R4S"    # <- 添加
```

完成。每个设备的定制逻辑完全独立，互不影响。

## 许可证

[MIT](LICENSE)
