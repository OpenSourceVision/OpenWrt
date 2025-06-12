#!/bin/sh
# OpenWrt 24.0.0 主路由配置脚本

echo "开始配置OpenWrt主路由模式..."

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
uci set system.@system[0].hostname='MainRouter'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# 3. 配置NTP服务器
uci -q delete system.ntp.server
uci add_list system.ntp.server='ntp.aliyun.com'
uci add_list system.ntp.server='cn.pool.ntp.org'
uci commit system

# 4. 配置WAN接口 - 拨号上网
uci set network.wan.proto='pppoe'
uci set network.wan.username='你的宽带账号'
uci set network.wan.password='你的宽带密码'
uci commit network

# 5. 配置LAN接口 - 主路由模式
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.110.1'
uci set network.lan.netmask='255.255.255.0'
uci -q delete network.lan.dns
uci add_list network.lan.dns='223.5.5.5'
uci add_list network.lan.dns='114.114.114.114'
uci commit network

# 6. 启用DHCP服务
uci set dhcp.lan.ignore='0'
uci set dhcp.lan.start='100'
uci set dhcp.lan.limit='150'
uci set dhcp.lan.leasetime='12h'
# 为旁路由预留IP
uci set dhcp.@host[0]=host
uci set dhcp.@host[0].name='bypass-router'
uci set dhcp.@host[0].mac='你的旁路由MAC地址'
uci set dhcp.@host[0].ip='192.168.110.110'
uci commit dhcp

# 7. 配置防火墙 - 标准安全设置
uci set firewall.@defaults[0].input='ACCEPT'
uci set firewall.@defaults[0].output='ACCEPT'
uci set firewall.@defaults[0].forward='REJECT'
uci set firewall.@defaults[0].syn_flood='1'
uci commit firewall

# 8. 启用无线功能
for i in 0 1; do
    if uci get wireless.radio${i} 2>/dev/null; then
        uci set wireless.radio${i}.disabled='0'
        uci set wireless.radio${i}.country='CN'
        uci set wireless.radio${i}.channel='auto'
        
        # 配置WiFi
        uci set wireless.default_radio${i}.ssid='OpenWrt-Main'
        uci set wireless.default_radio${i}.encryption='psk2'
        uci set wireless.default_radio${i}.key='12345678'
        uci set wireless.default_radio${i}.disabled='0'
    fi
done
uci commit wireless

# 9. 设置中文界面
uci set luci.main.lang='zh_cn'
uci commit luci

# 10. 启用IP转发
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

# 11. 更新软件包列表
echo "更新软件包列表..."
opkg update

# 重启相关服务
/etc/init.d/network reload
/etc/init.d/firewall reload
/etc/init.d/dnsmasq restart

echo "================================================"
echo "OpenWrt主路由配置完成！"
echo "WiFi名称: OpenWrt-Main"
echo "WiFi密码: 12345678"
echo "请重启系统: reboot"
echo "================================================"
