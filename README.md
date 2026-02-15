# OpenWrt 24.0.0 配置指南

## 概述

OpenWrt 自动化配置方案，支持旁路由和主路由模式，使用 uci-defaults 脚本一键完成中文界面、网络优化等配置。

**推荐使用 ImmortalWrt**（删除脚本中的软件源部分）
## 自定义配置

### 修改 IP 地址
```bash
# 旁路由
uci set network.lan.ipaddr='你的IP'
uci set network.lan.gateway='网关IP'

# 主路由
uci set network.lan.ipaddr='你的IP'
```

### 修改 WiFi（主路由）
```bash
uci set wireless.default_radio0.ssid='WiFi名称'
uci set wireless.default_radio0.key='WiFi密码'
```


## 固件构建

### 1. 访问
- **OpenWrt**: [点击访问](https://firmware-selector.openwrt.org/)
- **ImmortalWrt**: [点击访问](https://firmware-selector.immortalwrt.org/)

### 2. 选择设备版本
输入设备型号，选择自己想要的版本 **24.X.X**

### 3. 添加预装软件包
**OpenWrt 24 系统必装软件：**
```
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn openssh-sftp-server curl wget-ssl nano htop iperf3
```

**ImmortalWrt 24 系统必装软件：**
```
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn openssh-sftp-server curl wget-ssl nano htop iperf3 luci-theme-argon luci-app-diskman
```
#### 如图所示：
<img src="https://github.com/OpenSourceVision/OpenWrt/blob/ba8247cd948133a3d7bd8100203a09cfd75a5769/%E9%A2%84%E5%AE%89%E8%A3%85%E7%9A%84%E8%BD%AF%E4%BB%B6%E5%8C%85.png" />

### 4. 添加配置脚本
根据需要选择对应脚本复制到 **"首次启动时运行的脚本（uci-defaults）"**：

- **旁路由**：`OpenWrt_Bypass.sh` [直达脚本](https://raw.githubusercontent.com/OpenSourceVision/OpenWrt/refs/heads/main/OpenWrt_Bypass.sh)
- **主路由**：`OpenWrt_Main_Router.sh` [直达脚本](https://raw.githubusercontent.com/OpenSourceVision/OpenWrt/refs/heads/main/OpenWrt_Main_Router.sh)
- #### 如图所示：
<img src="https://github.com/OpenSourceVision/OpenWrt/blob/ba8247cd948133a3d7bd8100203a09cfd75a5769/%E9%A6%96%E6%AC%A1%E5%90%AF%E5%8A%A8%E6%97%B6%E8%BF%90%E8%A1%8C%E7%9A%84%E8%84%9A%E6%9C%AC%EF%BC%88uci-defaults%EF%BC%89.png" />

### 5. 构建下载
点击 **"请求构建"**

下载固件，推荐下载 **COMBINED-EFI (SQUASHFS)** 镜像

## 配置模式

### 🔀 旁路由模式
**适用**：已有主路由，增强网络功能
- IP：192.168.110.110/24
- 网关：192.168.110.1
- DNS：223.5.5.5, 192.168.110.1
- 禁用 DHCP 和 WiFi

### 🌐 主路由模式
**适用**：替换现有路由器
- IP：192.168.110.110/24
- WiFi：OpenWrt-Main / 12345678
- 启用 DHCP 和 WiFi
- ⚠️ **需修改脚本中的宽带账号密码**


## 使用说明

### 访问管理
- Web：http://192.168.110.110
- SSH：`ssh root@192.168.110.110`
- 默认无密码，首次登录需设置

### 注意事项
- 首次启动后建议重启
- 务必设置管理员密码
