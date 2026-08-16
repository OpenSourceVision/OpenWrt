#!/bin/sh
# OpenWrt 25.12 旁路由配置脚本

echo "开始配置 OpenWrt 25.12 旁路由模式..."

# 1. 系统基本设置 (时区与 NTP)
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'

uci -q delete system.ntp.server
uci add_list system.ntp.server='ntp.aliyun.com'
uci add_list system.ntp.server='cn.pool.ntp.org'
uci commit system

# 2. 配置 LAN 接口 - 旁路由模式
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.110.110'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.110.1'
uci -q delete network.lan.dns
uci add_list network.lan.dns='223.5.5.5'
uci add_list network.lan.dns='192.168.110.1'
uci commit network

# 3. 禁用 LAN 口 DHCP 功能
echo "禁用 DHCP 服务..."
uci set dhcp.lan.ignore='1'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra='disabled'
uci -q delete dhcp.lan.start
uci -q delete dhcp.lan.limit
uci -q delete dhcp.lan.leasetime
uci commit dhcp

# 4. 防火墙配置 (适配 25.12 fw4 架构)
echo "配置防火墙规则..."
uci set firewall.@defaults[0].input='ACCEPT'
uci set firewall.@defaults[0].output='ACCEPT'
uci set firewall.@defaults[0].forward='ACCEPT'

# 安全删除 WAN 区域（按名称精确删除，避免硬编码数组索引报错）
uci -q delete firewall.wan
uci -q delete firewall.wan6

# 配置 LAN 区域参数
uci set firewall.lan.input='ACCEPT'
uci set firewall.lan.output='ACCEPT'
uci set firewall.lan.forward='ACCEPT'
# 若主路由不支持自定义网关导致无回应，可将 masq 改为 '1' 开启动态伪装
uci set firewall.lan.masq='0'

uci commit firewall

# 5. 禁用无线功能
for i in 0 1 2 3; do
    uci set wireless.radio${i}.disabled='1' 2>/dev/null || true
done
uci commit wireless

# 6. 设置中文界面 (适配 25.12 新版 LuCI 语言标识)
uci set luci.main.lang='zh_Hans' 2>/dev/null || uci set luci.main.lang='zh_cn'
uci commit luci

# 7. 开启内核 IP 转发 (采用 25.12 推荐的 sysctl.d 独立文件规范)
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-ipforward.conf
sysctl -p /etc/sysctl.d/99-ipforward.conf 2>/dev/null || true

# 8. 停止并彻底禁用 DHCP 相关服务
echo "停止与禁用 DHCP 服务..."
/etc/init.d/odhcpd stop 2>/dev/null
/etc/init.d/odhcpd disable 2>/dev/null
/etc/init.d/dnsmasq stop 2>/dev/null
/etc/init.d/dnsmasq disable 2>/dev/null

# 9. 重启网络与防火墙服务
echo "重载网络配置..."
/etc/init.d/network reload
/etc/init.d/firewall reload

echo "================================================"
echo "OpenWrt 25.12 旁路由配置完成！"
echo "建议执行命令重启设备: reboot"
echo "================================================"
