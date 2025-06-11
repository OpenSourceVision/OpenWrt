# OpenWrt uci-defaults 脚本使用说明

## 概述


## 自定义配置

### 🎛️ 修改IP地址

修改默认IP地址，编辑脚本中的以下部分：

```bash
uci set network.lan.ipaddr='你的IP地址'
uci set network.lan.gateway='你的网关地址'
```

## 使用说明

### 步骤1：访问固件选择器

打开 https://firmware-selector.openwrt.org/

### 步骤2：选择设备和版本

1. 输入你的设备型号
2. 选择版本：**24.0.0**


### 步骤3：添加预装软件包

在 **"预安装的软件包"** 后面复制粘贴：

**OpenWrt 24 系统必装软件：**
```
luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn openssh-sftp-server curl wget-ssl nano htop iperf3
```
#### 如图所示：
<img src="https://github.com/OpenSourceVision/OpenWrt/blob/ba8247cd948133a3d7bd8100203a09cfd75a5769/%E9%A2%84%E5%AE%89%E8%A3%85%E7%9A%84%E8%BD%AF%E4%BB%B6%E5%8C%85.png" />
  
### 步骤4：添加首次启动脚本

在 **"首次启动时运行的脚本（uci-defaults）"** 部分，将本仓库中的完整脚本代码复制并粘贴到输入框中。

#### 如图所示：
<img src="https://github.com/OpenSourceVision/OpenWrt/blob/ba8247cd948133a3d7bd8100203a09cfd75a5769/%E9%A6%96%E6%AC%A1%E5%90%AF%E5%8A%A8%E6%97%B6%E8%BF%90%E8%A1%8C%E7%9A%84%E8%84%9A%E6%9C%AC%EF%BC%88uci-defaults%EF%BC%89.png" />

### 步骤5：请求构建

点击 **"请求构建"** 按钮，等待固件构建完成。

### 步骤6：下载镜像文件

**推荐下载：COMBINED-EFI (SQUASHFS)镜像文件**


### 步骤7：刷写固件



## 首次启动后

### 🌍 访问管理界面

- **Web管理**: http://192.168.110.110
- **SSH访问**: `ssh root@192.168.110.110`
- **默认用户**: root（无密码，首次登录需设置

---
