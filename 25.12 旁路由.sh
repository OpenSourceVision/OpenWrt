#!/bin/sh
# OpenWrt 25.12 旁路由配置脚本

echo "开始配置OpenWrt旁路由模式..."

# 1. 系统基本设置
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# 2. 配置NTP服务器
uci -q delete system.ntp.server
uci add_list system.ntp.server='ntp.aliyun.com'
uci add_list system.ntp.server='cn.pool.ntp.org'
uci commit system

# 3. 配置LAN接口
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.110.110'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.110.1'
uci -q delete network.lan.dns
uci add_list network.lan.dns='223.5.5.5'
uci add_list network.lan.dns='192.168.110.1'
uci commit network

# 4. 禁用DHCP
uci set dhcp.lan.ignore='1'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra='disabled'
uci commit dhcp

# 5. 配置防火墙
uci set firewall.@defaults[0].input='ACCEPT'
uci set firewall.@defaults[0].output='ACCEPT'
uci set firewall.@defaults[0].forward='ACCEPT'

WAN_ZONE=$(uci show firewall | grep "\.name='wan'" | grep -o 'firewall\.@zone\[[0-9]*\]' | head -1)
[ -n "$WAN_ZONE" ] && uci -q delete "$WAN_ZONE"

WAN_FWD=$(uci show firewall | grep "\.dest='wan'" | grep -o 'firewall\.@forwarding\[[0-9]*\]' | head -1)
[ -n "$WAN_FWD" ] && uci -q delete "$WAN_FWD"

uci commit firewall

# 6. 启用IP转发
grep -q 'net.ipv4.ip_forward=1' /etc/sysctl.conf || echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -w net.ipv4.ip_forward=1

# 7. 停止DHCP相关服务
/etc/init.d/dnsmasq stop
/etc/init.d/odhcpd stop
/etc/init.d/odhcpd disable

# 8. 重载服务
/etc/init.d/network reload
/etc/init.d/firewall reload

echo "================================================"
echo "旁路由配置完成！"
echo "设备IP:   192.168.110.110"
echo "上级网关: 192.168.110.1"
echo "请重启:   reboot"
echo "================================================"
