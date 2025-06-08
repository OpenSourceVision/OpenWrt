# OpenWrt 24.0.0 快速配置指南

## 🎯 概述

OpenWrt 自动化配置方案，支持旁路由和主路由两种模式。使用 ImmortalWrt 软件源，一键完成中文界面、网络优化等配置。

## 📣 特殊说明

同样适用于ImmortalWrt的构建。

## 🏗️ 固件构建

### 1. 访问固件选择器
打开 https://firmware-selector.openwrt.org/

### 2. 配置预装软件包
[软件清单](https://github.com/OpenSourceVision/OpenWrt/blob/main/OpenWrt.md)
### 3. 添加配置脚本
将下方对应的脚本复制到 **"首次启动时运行的脚本（uci-defaults）"** 中。

### 4. 构建下载
点击 **"请求构建"**，下载镜像。

---

## 🔀 旁路由配置

**适用场景：** 已有主路由，需要增强网络功能

**默认配置：**
- IP地址：192.168.X.110
- 网关：192.168.X.1
- 禁用DHCP和WiFi

**配置脚本：** [OpenWrt_Bypass.sh](https://github.com/OpenSourceVision/OpenWrt/blob/main/OpenWrt_Bypass.sh)

---

## 🌐 主路由配置

**适用场景：** 替换现有路由器，提供完整路由功能

**默认配置：**
- IP地址：192.168.X.1
- 启用DHCP和WiFi
- WiFi名称：OpenWrt-Main，密码：12345678

**配置脚本：** [openwrt_Main Router.sh](https://github.com/OpenSourceVision/OpenWrt/blob/main/openwrt_Main%20Router.sh)

**⚠️ 使用前需要修改脚本中的宽带账号和密码**

---

## 📝 使用说明

[使用说明](https://github.com/OpenSourceVision/OpenWrt/blob/main/OpenWrt.md)

## ⚠️ 注意事项

- 首次启动后建议重启系统
- 默认无密码，首次登录需设置管理员密码

---

## 🔧 自定义配置

### 修改IP地址
```bash
# 旁路由
uci set network.lan.ipaddr='你的IP地址'
uci set network.lan.gateway='你的网关地址'

# 主路由
uci set network.lan.ipaddr='你的IP地址'
```

### 修改WiFi信息
```bash
uci set wireless.default_radio0.ssid='你的WiFi名称'
uci set wireless.default_radio0.key='你的WiFi密码'
```

---

