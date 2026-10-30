#!/bin/sh
# 旁路由（单臂）配置：静态 LAN + NAT + 内核参数  用法：sh bypass.sh && reboot

# 动态取 LAN 设备：DSA 机型是 br-lan，x86 直接配在 eth0 时就是 eth0，不能写死
LAN_DEV=$(uci get network.lan.device 2>/dev/null)
[ -z "$LAN_DEV" ] && LAN_DEV=br-lan

uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci -q delete system.ntp.server
uci add_list system.ntp.server='ntp.aliyun.com'
uci add_list system.ntp.server='cn.pool.ntp.org'
uci commit system

uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.110.110'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.110.1'
uci -q delete network.lan.dns
uci add_list network.lan.dns='223.5.5.5'
uci add_list network.lan.dns='192.168.110.1'
uci commit network

uci set dhcp.lan.ignore='1'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra='disabled'
uci commit dhcp

uci set firewall.@defaults[0].input='ACCEPT'
uci set firewall.@defaults[0].output='ACCEPT'
uci set firewall.@defaults[0].forward='ACCEPT'

# 透明代理靠 netfilter 转发，flowtable 会让已建立的流绕过它
uci set firewall.@defaults[0].flow_offloading='0'
uci set firewall.@defaults[0].flow_offloading_hw='0'

WAN_ZONE=$(uci show firewall | grep "\.name='wan'" | grep -o 'firewall\.@zone\[[0-9]*\]' | head -1)
[ -n "$WAN_ZONE" ] && uci -q delete "$WAN_ZONE"
WAN_FWD=$(uci show firewall | grep "\.dest='wan'" | grep -o 'firewall\.@forwarding\[[0-9]*\]' | head -1)
[ -n "$WAN_FWD" ] && uci -q delete "$WAN_FWD"

LAN_ZONE=$(uci show firewall | grep "\.name='lan'" | grep -o 'firewall\.@zone\[[0-9]*\]' | head -1)
[ -z "$LAN_ZONE" ] && LAN_ZONE='firewall.@zone[0]'

# 不开 NAT：客户端包源地址不变，回包被主路由直接送回客户端，绕过本机 → 连接等到超时
uci set "${LAN_ZONE}.masq=1"
uci set "${LAN_ZONE}.mtu_fix=1"

uci commit firewall

# 单臂转发：进出是同一个接口，内核会给客户端发 ICMP 重定向，把流量引向主路由
cat > /etc/sysctl.d/60-bypass.conf <<EOF
net.ipv4.ip_forward = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.rp_filter = 0
EOF

# 内核取 all 与具体接口里的较宽松值，所以接口上也得是 0
case "$LAN_DEV" in
*.*) : ;;
*)
	cat >> /etc/sysctl.d/60-bypass.conf <<EOF
net.ipv4.conf.${LAN_DEV}.send_redirects = 0
net.ipv4.conf.${LAN_DEV}.accept_redirects = 0
net.ipv4.conf.${LAN_DEV}.rp_filter = 0
EOF
	;;
esac

/etc/init.d/odhcpd stop
/etc/init.d/odhcpd disable
/etc/init.d/network reload
/etc/init.d/firewall reload
sysctl -p /etc/sysctl.d/60-bypass.conf >/dev/null 2>&1
if [ -e "/proc/sys/net/ipv4/conf/${LAN_DEV}/send_redirects" ]; then
	echo 0 > "/proc/sys/net/ipv4/conf/${LAN_DEV}/send_redirects"
	echo 0 > "/proc/sys/net/ipv4/conf/${LAN_DEV}/accept_redirects"
	echo 0 > "/proc/sys/net/ipv4/conf/${LAN_DEV}/rp_filter"
fi

echo "LAN=${LAN_DEV} masq=$(uci get "${LAN_ZONE}.masq") offload=$(uci get firewall.@defaults[0].flow_offloading)"
sysctl net.ipv4.ip_forward net.ipv4.conf.all.send_redirects net.ipv4.conf.all.accept_redirects net.ipv4.conf.all.rp_filter
echo "done, reboot"
