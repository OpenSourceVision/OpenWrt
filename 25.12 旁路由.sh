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

# 3. 配置LAN接口 - 旁路由模式
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.110.110'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.110.1'
uci -q delete network.lan.dns
uci add_list network.lan.dns='223.5.5.5'
uci add_list network.lan.dns='192.168.110.1'
uci commit network

# 4. 完全禁用DHCP服务
echo "禁用DHCP相关服务..."
uci set dhcp.lan.ignore='1'
uci set dhcp.@dnsmasq[0].enable_tftp='0'
uci -q delete dhcp.lan.start
uci -q delete dhcp.lan.limit
uci -q delete dhcp.lan.leasetime
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra='disabled'
uci commit dhcp

# 5. 配置防火墙
echo "配置防火墙规则..."
uci set firewall.@defaults[0].input='ACCEPT'
uci set firewall.@defaults[0].output='ACCEPT'
uci set firewall.@defaults[0].forward='ACCEPT'

# 按 name 精确删除 WAN zone，避免匿名索引删错
WAN_ZONE=$(uci show firewall | grep "\.name='wan'" | grep -o 'firewall\.@zone\[[0-9]*\]' | head -1)
if [ -n "$WAN_ZONE" ]; then
    echo "删除WAN zone: $WAN_ZONE"
    uci -q delete "$WAN_ZONE"
fi

# 按 name 精确删除 LAN→WAN forwarding
WAN_FWD=$(uci show firewall | grep "\.dest='wan'" | grep -o 'firewall\.@forwarding\[[0-9]*\]' | head -1)
if [ -n "$WAN_FWD" ]; then
    echo "删除LAN->WAN forwarding: $WAN_FWD"
    uci -q delete "$WAN_FWD"
fi

# 配置 LAN zone
LAN_ZONE=$(uci show firewall | grep "\.name='lan'" | grep -o 'firewall\.@zone\[[0-9]*\]' | head -1)
if [ -n "$LAN_ZONE" ]; then
    uci set ${LAN_ZONE}.input='ACCEPT'
    uci set ${LAN_ZONE}.output='ACCEPT'
    uci set ${LAN_ZONE}.forward='ACCEPT'
    uci set ${LAN_ZONE}.masq='0'
fi

uci commit firewall

# 6. 禁用无线功能
echo "禁用无线功能..."
for i in 0 1 2; do
    uci set wireless.radio${i}.disabled='1' 2>/dev/null || true
done
uci commit wireless

# 7. 设置中文界面
uci set luci.main.lang='zh_cn'
uci commit luci

# 8. 启用IP转发
if ! grep -q 'net.ipv4.ip_forward=1' /etc/sysctl.conf; then
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
fi
sysctl -w net.ipv4.ip_forward=1

# 9. 先更新软件包（在 dnsmasq 停止之前，DNS 还可用）
echo "更新软件包列表..."
apk update

# 10. 停止并禁用DHCP相关服务
echo "停止DHCP相关服务..."
/etc/init.d/dnsmasq stop
/etc/init.d/odhcpd stop
/etc/init.d/odhcpd disable

# 11. 重载相关服务
/etc/init.d/network reload
/etc/init.d/firewall reload

echo "================================================"
echo "OpenWrt 25.12 旁路由配置完成！"
echo "设备IP:    192.168.110.110"
echo "上级网关:  192.168.110.1"
echo "DHCP:      已关闭"
echo "WAN zone:  已移除"
echo "请重启系统: reboot"
echo "================================================"
