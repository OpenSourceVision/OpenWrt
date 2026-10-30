# OpenWrt / ImmortalWrt 25.12 旁路由配置指南

## 概述

旁路由（单臂网关）自动化配置方案：用 uci-defaults 脚本一次完成中文界面、网络参数、关闭 DHCP 等配置。

**推荐使用 ImmortalWrt**（删除脚本中的软件源部分）。

## 自定义配置

### 修改 IP 地址

```bash
uci set network.lan.ipaddr='你的IP'
uci set network.lan.gateway='上级网关IP'
```

## 固件构建

### 1. 访问

- **OpenWrt**: [点击访问](https://firmware-selector.openwrt.org/)
- **ImmortalWrt**: [点击访问](https://firmware-selector.immortalwrt.org/)

### 2. 选择设备版本

输入设备型号，选择自己想要的版本。

### 3. 添加预装软件包

**OpenWrt 系统必装软件：**

```
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn openssh-sftp-server curl wget-ssl nano htop iperf3
```

**ImmortalWrt 系统必装软件：**【无 Docker】

```
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn openssh-sftp-server curl wget-ssl nano htop iperf3 luci-theme-argon luci-app-diskman luci-i18n-diskman-zh-cn luci-app-ttyd
```

**ImmortalWrt 系统必装软件：**【有 Docker】

```
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn openssh-sftp-server curl wget-ssl nano htop iperf3 luci-theme-argon luci-app-diskman luci-i18n-diskman-zh-cn docker dockerd docker-compose luci-lib-docker luci-app-dockerman luci-i18n-dockerman-zh-cn luci-app-ttyd
```

#### 如图所示：

<img src="https://github.com/OpenSourceVision/OpenWrt/blob/ba8247cd948133a3d7bd8100203a09cfd75a5769/%E9%A2%84%E5%AE%89%E8%A3%85%E7%9A%84%E8%BD%AF%E4%BB%B6%E5%8C%85.png" />

### 4. 添加配置脚本

把旁路由脚本复制到 **“首次启动时运行的脚本（uci-defaults）”**：

- **旁路由**：`OpenWrt_Bypass.sh` [直达脚本](https://raw.githubusercontent.com/OpenSourceVision/OpenWrt/refs/heads/main/OpenWrt_Bypass.sh)

#### 如图所示：

<img src="https://github.com/OpenSourceVision/OpenWrt/blob/ba8247cd948133a3d7bd8100203a09cfd75a5769/%E9%A6%96%E6%AC%A1%E5%90%AF%E5%8A%A8%E6%97%B6%E8%BF%90%E8%A1%8C%E7%9A%84%E8%84%9A%E6%9C%AC%EF%BC%88uci-defaults%EF%BC%89.png" />

### 5. 构建下载

点击 **“请求构建”**。

下载固件，推荐下载 **COMBINED-EFI (SQUASHFS)** 镜像。

## 旁路由模式

**适用**：已有上级路由器，旁路由只负责增强功能（代理、DNS 分流、广告过滤等），不改变现有网络拓扑。

| 项 | 值 |
|---|---|
| IP | 192.168.110.110 |
| 网关 | 192.168.110.1 |
| DNS | 223.5.5.5、192.168.110.1 |
| DHCP | 关闭（地址由上级路由分配） |
| RA / DHCPv6 | 关闭 |
| WiFi | 不启用（或仅作 AP，SSID 与上级路由分开） |

脚本默认写入的关键项：

- **lan 区 `masquerade=1`**：不做 NAT 时，客户端包源地址不变，回包会被上级路由直接送回客户端，绕过旁路由，表现为“能上但很慢、要等很久才连上”；
- **`send_redirects=0`、`accept_redirects=0`、`rp_filter=0`**：单臂转发进出同一接口，内核默认会向客户端发 ICMP 重定向，把流量引向主路由；
- **关闭 flow offloading**：flowtable 会让已建立的转发流绕过 netfilter，透明代理会漏流；
- **`mtu_fix=1`**：上级路由是 PPPoE 时，钳制 MSS，避免大包卡住。

### 客户端怎么用

二选一：

1. 手机/电脑手动设置：网关填 `192.168.110.110`，DNS 也填 `192.168.110.110`；
2. 在上级路由的 DHCP 里把网关和 DNS 下发为 `192.168.110.110`（需要上级路由可管理）。

> DNS 必须指向旁路由，否则域名分流不生效。

## 使用说明

### 访问管理

- Web：`http://192.168.110.110`
- SSH：`ssh root@192.168.110.110`
- 默认无密码，首次登录需设置

### 注意事项

- 首次启动后建议重启
- 务必设置管理员密码
- 旁路由不要接上级路由的 WAN 口，只接 LAN 口
- 旁路由与上级路由不要同时开 DHCP

### 验证

```bash
# 网关与 NAT
uci get firewall.@zone[0].masq

# 单臂参数（都应为 0）
sysctl net.ipv4.conf.all.send_redirects net.ipv4.conf.all.accept_redirects net.ipv4.conf.all.rp_filter

# 客户端流量是否真的经过旁路由（看收包在增长）
ip -s link show br-lan
```
