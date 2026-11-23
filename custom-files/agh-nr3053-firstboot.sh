#!/bin/sh
# First-boot DNS integration: dnsmasq -> AdGuard Home.
set -e

# Seed a working upstream before the WAN hotplug script discovers ISP DNS.
mkdir -p /etc/adguardhome
if [ ! -s /etc/adguardhome/upstream_dns.txt ]; then
    printf '%s\n' '1.1.1.1' '1.0.0.1' > /etc/adguardhome/upstream_dns.txt
fi

# Keep dnsmasq on port 53 for LAN/DHCP, and forward its DNS queries to AGH.
uci set dhcp.@dnsmasq[0].noresolv='1'
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server='127.0.0.1#5353'

# Tell DHCP clients to use the router as their DNS server.
uci -q del_list dhcp.lan.dhcp_option='6,192.168.1.1'
uci add_list dhcp.lan.dhcp_option='6,192.168.1.1'
uci commit dhcp

/etc/init.d/adguardhome enable
/etc/init.d/dnsmasq restart
/etc/init.d/adguardhome restart || true

exit 0
