# OpenWrt uci-defaults 脚本使用说明

## 概述

本脚本是针对 OpenWrt 24.10.1 系统的自动化配置脚本，使用 ImmortalWrt 软件源，专门为旁路由模式设计。脚本会在系统首次启动时自动执行，完成网络、防火墙、服务等基础配置。

## 脚本功能

### 🌐 网络配置
- 设置静态IP：192.168.110.110/24
- 配置网关：192.168.110.1
- DNS服务器：223.5.5.5, 192.168.110.1
- 禁用DHCP服务（旁路由模式）

### 🔧 系统优化
- 时区设置：Asia/Shanghai (CST-8)
- 启用IP转发
- 网络性能优化参数
- 中文管理界面

### 📦 软件源配置
- 使用 ImmortalWrt 24.04 软件源
- 提供多个国内镜像源备选
- 自动更新软件包列表

### 🔒 安全配置
- SSH服务配置（端口22）
- 防火墙开放模式设置
- 禁用无线功能

## 使用方法

### 步骤1：访问固件选择器

打开 [OpenWrt 固件选择器](https://firmware-selector.openwrt.org/)

### 步骤2：选择设备型号

1. 在搜索框中输入你的设备型号
2. 选择正确的硬件版本
3. 确认选择的是 **24.10.1** 版本

### 步骤3：添加脚本

1. 在页面中找到 **"首次运行脚本"** 或 **"First boot script"** 部分
2. 将本仓库中的完整脚本代码复制并粘贴到输入框中

![固件选择器示例](https://via.placeholder.com/600x300/2196F3/FFFFFF?text=OpenWrt+Firmware+Selector)

### 步骤4：下载固件

1. 点击 **"下载固件"** 或 **"Download firmware"** 按钮
2. 选择适合你设备的固件格式（通常是 `.img` 或 `.bin` 文件）

### 步骤5：刷写固件

将下载的固件刷入你的设备，具体方法因设备而异：
- Web界面升级
- TFTP刷写
- U-Boot刷写
- 其他厂商特定方法

## 首次启动后

### 🔍 检查配置

系统启动后，脚本会自动执行并在 `/tmp/uci-defaults.log` 中记录执行日志。

```bash
# 查看脚本执行日志
cat /tmp/uci-defaults.log

# 检查网络配置
ip addr show
uci show network.lan
```

### 🌍 访问管理界面

- **Web管理**: http://192.168.110.110
- **SSH访问**: `ssh root@192.168.110.110`
- **默认用户**: root（无密码，首次登录需设置）

### ⚙️ 后续配置

1. **设置管理员密码**
   ```bash
   passwd
   ```

2. **更新软件包**
   ```bash
   update-feeds  # 使用脚本提供的便捷命令
   # 或者
   opkg update
   ```


### 📦 常用软件包

使用 ImmortalWrt 软件源后，可以安装更多软件包：

```bash
# 网络工具
opkg install curl wget htop

# 科学上网相关
opkg install luci-app-passwall luci-app-ssr-plus

# 广告屏蔽
opkg install luci-app-adbyby-plus

# 网络加速
opkg install luci-app-turboacc
```

## 故障排除

### 🔧 常见问题

**Q: 无法访问管理界面？**
- 检查设备IP是否为 192.168.110.110
- 确认电脑与设备在同一网段
- 检查防火墙设置

**Q: 无法上网？**
- 确认主路由DHCP设置正确
- 检查网关配置：`uci show network.lan.gateway`
- 验证DNS设置：`nslookup baidu.com`

**Q: 软件包安装失败？**
- 更新软件源：`opkg update`
- 检查网络连接
- 尝试切换镜像源

### 📝 日志查看

```bash
# 脚本执行日志
cat /tmp/uci-defaults.log

# 系统启动日志
dmesg

# 网络服务日志
logread | grep network
```

## 自定义配置

### 🎛️ 修改IP地址

如需修改默认IP地址，编辑脚本中的以下部分：

```bash
uci set network.lan.ipaddr='你的IP地址'
uci set network.lan.gateway='你的网关地址'
```

### 🔧 其他自定义

脚本支持以下自定义：
- 修改主机名
- 调整DNS服务器
- 启用/禁用特定服务
- 修改防火墙规则

## 注意事项

⚠️ **重要提醒**：
- 本脚本专为旁路由模式设计，不适用于主路由
- 刷机有风险，操作前请确保了解设备的救砖方法
- 首次使用建议在测试环境中验证
- 不同设备可能需要微调脚本参数

## 技术支持

如遇问题，可以：
1. 查看 OpenWrt 官方文档
2. 访问 ImmortalWrt 社区论坛
3. 检查设备特定的使用说明

---

**最后更新**: 2025年6月
**适用版本**: OpenWrt 24.10.1
**软件源**: ImmortalWrt 24.04
