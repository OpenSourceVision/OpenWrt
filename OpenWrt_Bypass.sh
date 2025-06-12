#!/bin/sh
# OpenWrt 24.0.0 旁路由配置脚本

echo "开始配置OpenWrt旁路由模式..."

# 1. 配置ImmortalWrt软件源
echo "配置ImmortalWrt软件源..."
cat > /etc/opkg/distfeeds.conf << 'EOF'
src/gz immortalwrt_core https://downloads.immortalwrt.org/releases/24.04/targets/x86/64/packages
src/gz immortalwrt_base https://downloads.immortalwrt.org/releases/24.04/packages/x86_64/base
src/gz immortalwrt_luci https://downloads.immortalwrt.org/releases/24.04/packages/x86_64/luci
src/gz immortalwrt_packages https://downloads.immortalwrt.org/releases/24.04/packages/x86_64/packages
src/gz immortalwrt_routing https://downloads.immortalwrt.org/releases/24.04/packages/x86_64/routing
src/gz immortalwrt_telephony https://downloads.immortalwrt.org/releases/24.04/packages/x86_64/telephony
src/gz immortalwrt_kmod https://downloads.immortalwrt.org/releases/24.04/targets/x86/64/kmods
EOF

# 2. 系统基本设置
uci set system.@system[0].hostname='OpenWrt'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# 3. 配置NTP服务器
uci -q delete system.ntp.server
uci add_list system.ntp.server='ntp.aliyun.com'
uci add_list system.ntp.server='cn.pool.ntp.org'
uci commit system

# 4. 配置LAN接口 - 旁路由模式
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.110.110'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.110.1'
uci -q delete network.lan.dns
uci add_list network.lan.dns='223.5.5.5'
uci add_list network.lan.dns='192.168.110.1'
uci commit network

# 5. 完全禁用DHCP服务
echo "禁用DHCP相关服务..."
uci set dhcp.lan.ignore='1'
uci set dhcp.@dnsmasq[0].enable_tftp='0'
uci set dhcp.@dnsmasq[0].tftp_root='/tmp/tftp'
uci set dhcp.@dnsmasq[0].dhcp_boot=''
# 禁用所有DHCP池
uci -q delete dhcp.lan.start
uci -q delete dhcp.lan.limit
uci -q delete dhcp.lan.leasetime
# 禁用DHCPv6
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra='disabled'
uci commit dhcp

# 6. 配置防火墙 - 关闭WAN口
echo "配置防火墙规则..."
uci set firewall.@defaults[0].input='ACCEPT'
uci set firewall.@defaults[0].output='ACCEPT'
uci set firewall.@defaults[0].forward='ACCEPT'

# 删除WAN口相关的防火墙规则
uci -q delete firewall.@zone[1] 2>/dev/null || true  # 删除WAN zone
uci -q delete firewall.@forwarding[0] 2>/dev/null || true  # 删除LAN到WAN的转发规则

# 创建仅LAN的防火墙zone
uci set firewall.@zone[0].name='lan'
uci set firewall.@zone[0].input='ACCEPT'
uci set firewall.@zone[0].output='ACCEPT'
uci set firewall.@zone[0].forward='ACCEPT'
uci set firewall.@zone[0].masq='0'
uci -q delete firewall.@zone[0].network
uci add_list firewall.@zone[0].network='lan'

uci commit firewall

# 7. 禁用无线功能
for i in 0 1 2; do
    uci set wireless.radio${i}.disabled='1' 2>/dev/null || true
done
uci commit wireless

# 8. 设置中文界面
uci set luci.main.lang='zh_cn'
uci commit luci

# 9. 启用IP转发
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

# 10. 停止并禁用DHCP相关服务
echo "停止DHCP相关服务..."
/etc/init.d/dnsmasq stop
/etc/init.d/odhcpd stop
/etc/init.d/odhcpd disable

# 11. 更新软件包列表
echo "更新软件包列表..."
opkg update

# 重启相关服务
/etc/init.d/network reload
/etc/init.d/firewall reload

echo "================================================"
echo "OpenWrt旁路由配置完成！"
echo "DHCP服务已完全关闭"
echo "防火墙WAN口已关闭"
echo "请重启系统: reboot"
echo "================================================"
