
# OpenWrt 24.10.1 uci-defaults 首次启动配置脚本
# 旁路由模式 - IP: 192.168.110.110

# 设置脚本执行日志
exec > /tmp/uci-defaults.log 2>&1
echo "开始执行 OpenWrt 24.10.1 首次启动配置..."
echo "时间: $(date)"

# 2. 配置系统设置 - 上海时区
echo "=== 配置系统设置 ==="
uci set system.@system[0].hostname='OpenWrt'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci set system.@system[0].log_size='64'
uci commit system

# 3. 配置NTP服务器
echo "=== 配置NTP服务器 ==="
# 24.10.1版本使用新的NTP配置方式
uci -q delete system.ntp.server
uci add_list system.ntp.server='ntp.aliyun.com'
uci add_list system.ntp.server='time1.cloud.tencent.com'
uci add_list system.ntp.server='cn.pool.ntp.org'
uci set system.ntp.enabled='1'
uci set system.ntp.enable_server='0'
uci commit system

# 4. 配置网络设备 (24.10.1使用device配置)
echo "=== 配置网络设备 ==="
# 确保桥接设备存在
uci set network.@device[0]=device
uci set network.@device[0].name='br-lan'
uci set network.@device[0].type='bridge'
uci -q delete network.@device[0].ports
uci add_list network.@device[0].ports='eth0'
uci set network.@device[0].igmp_snooping='1'
uci set network.@device[0].stp='0'
uci commit network

# 5. 配置LAN接口 - 旁路由模式 (24.10.1配置方式)
echo "=== 配置LAN接口 ==="
uci set network.lan=interface
uci set network.lan.proto='static'
uci set network.lan.device='br-lan'
uci set network.lan.ipaddr='192.168.110.110'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.110.1'
uci set network.lan.broadcast='192.168.110.255'
uci set network.lan.delegate='0'

# 配置DNS
uci -q delete network.lan.dns
uci add_list network.lan.dns='223.5.5.5'
uci add_list network.lan.dns='192.168.110.1'
uci commit network

# 6. 禁用DHCP服务 - 旁路由模式
echo "=== 禁用DHCP服务 ==="
uci set dhcp.lan.ignore='1'
uci set dhcp.@dnsmasq[0].authoritative='0'
uci set dhcp.@dnsmasq[0].localservice='1'
uci set dhcp.@dnsmasq[0].domainneeded='1'
uci set dhcp.@dnsmasq[0].boguspriv='1'
uci commit dhcp

# 7. 配置防火墙 - 24.10.1防火墙配置
echo "=== 配置防火墙 ==="
# 默认规则配置
uci set firewall.@defaults[0].input='ACCEPT'
uci set firewall.@defaults[0].output='ACCEPT'
uci set firewall.@defaults[0].forward='ACCEPT'
uci set firewall.@defaults[0].syn_flood='1'
uci set firewall.@defaults[0].drop_invalid='0'

# LAN区域配置
uci set firewall.@zone[0].name='lan'
uci set firewall.@zone[0].input='ACCEPT'
uci set firewall.@zone[0].output='ACCEPT'
uci set firewall.@zone[0].forward='ACCEPT'
uci -q delete firewall.@zone[0].network
uci add_list firewall.@zone[0].network='lan'

# 如果存在WAN区域，也进行配置
uci set firewall.@zone[1].name='wan' 2>/dev/null || true
uci set firewall.@zone[1].input='REJECT' 2>/dev/null || true
uci set firewall.@zone[1].output='ACCEPT' 2>/dev/null || true
uci set firewall.@zone[1].forward='REJECT' 2>/dev/null || true
uci set firewall.@zone[1].masq='1' 2>/dev/null || true
uci set firewall.@zone[1].mtu_fix='1' 2>/dev/null || true

uci commit firewall

# 8. 配置SSH访问 (24.10.1使用dropbear)
echo "=== 配置SSH访问 ==="
uci set dropbear.@dropbear[0].PasswordAuth='on'
uci set dropbear.@dropbear[0].RootPasswordAuth='on'
uci set dropbear.@dropbear[0].Port='22'
uci set dropbear.@dropbear[0].Interface='lan'
uci commit dropbear

# 9. 禁用无线功能 (24.10.1可能有多个radio)
echo "=== 禁用无线功能 ==="
# 遍历所有可能的radio设备
for i in 0 1 2 3; do
    uci set wireless.radio${i}.disabled='1' 2>/dev/null || true
done
# 也禁用可能的default_radio配置
uci set wireless.default_radio0.disabled='1' 2>/dev/null || true
uci set wireless.default_radio1.disabled='1' 2>/dev/null || true
uci commit wireless


# 10. 设置默认语言为中文
echo "=== 设置中文界面 ==="
uci set luci.main.lang='zh_cn'
uci set luci.main.mediaurlbase='/luci-static/bootstrap'
uci commit luci

# 11. 配置系统参数
echo "=== 配置系统参数 ==="
# 启用IP转发
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.route_localnet=1' >> /etc/sysctl.conf

# 网络优化参数
echo 'net.core.rmem_max=134217728' >> /etc/sysctl.conf
echo 'net.core.wmem_max=134217728' >> /etc/sysctl.conf
echo 'net.netfilter.nf_conntrack_max=65536' >> /etc/sysctl.conf

# 12. 创建启动完成标记脚本
echo "=== 创建启动信息脚本 ==="
cat > /etc/rc.local << 'EOF'
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

# 确保IP转发开启
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv4/conf/all/route_localnet

# 优化网络参数
echo 134217728 > /proc/sys/net/core/rmem_max
echo 134217728 > /proc/sys/net/core/wmem_max

logger -t startup "OpenWrt 24.10.1 旁路由启动完成 - IP: 192.168.110.110"

# 显示启动信息
echo "=================================="
echo "OpenWrt 24.10.1 旁路由启动完成！"
echo "管理地址: http://192.168.110.110"
echo "SSH访问: ssh root@192.168.110.110"
echo "=================================="

exit 0
EOF

chmod +x /etc/rc.local

# 13. 重启相关服务
echo "=== 重启相关服务 ==="
/etc/init.d/network reload
/etc/init.d/firewall reload
/etc/init.d/uhttpd restart
/etc/init.d/dropbear restart
/etc/init.d/dnsmasq restart

# 14. 输出配置信息到日志
echo ""
echo "========================================="
echo "OpenWrt 24.10.1 旁路由首次配置完成！"
echo "========================================="
echo "版本信息: OpenWrt 24.10.1"
echo "配置时间: $(date)"
echo ""
echo "网络配置:"
echo "  设备IP: 192.168.110.110/24"
echo "  网关: 192.168.110.1"
echo "  DNS: 223.5.5.5, 192.168.110.1"
echo "  时区: Asia/Shanghai (CST-8)"
echo ""
echo "访问信息:"
echo "  Web管理: http://192.168.110.110"
echo "  SSH访问: ssh root@192.168.110.110"
echo "  管理界面: 中文"
echo ""
echo "功能状态:"
echo "  旁路由模式: 已启用"
echo "  DHCP服务: 已禁用"
echo "  无线功能: 已禁用"
echo "  SSH服务: 已启用 (端口22)"
echo "  防火墙: 已配置 (开放模式)"
echo "  软件源: 阿里云镜像"
echo "  IP转发: 已启用"
echo ""
echo "下一步操作:"
echo "  1. 重启系统: reboot"
echo "  2. 设置root密码: passwd"
echo "  3. 主路由DHCP指向此设备"
echo "  4. 检查网络连通性"
echo "========================================="

exit 0
