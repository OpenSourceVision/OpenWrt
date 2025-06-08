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

# 5. 禁用DHCP服务
uci set dhcp.lan.ignore='1'
uci commit dhcp

# 6. 配置防火墙为开放模式
uci set firewall.@defaults[0].input='ACCEPT'
uci set firewall.@defaults[0].output='ACCEPT'
uci set firewall.@defaults[0].forward='ACCEPT'
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

# 10. 更新软件包列表
echo "更新软件包列表..."
opkg update

# 重启相关服务
/etc/init.d/network reload
/etc/init.d/firewall reload
/etc/init.d/dnsmasq restart

echo "================================================"
echo "OpenWrt旁路由配置完成！"
echo "设备IP: 192.168.110.110"
echo "Web管理: http://192.168.110.110"
echo "请重启系统: reboot"
echo "================================================"
