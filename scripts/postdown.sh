#!/usr/bin/env bash
set -ex

sysctl net.ipv4.ip_forward=0

# Traffic forwarding
iptables -D FORWARD -i wg0 -j ACCEPT
iptables -D FORWARD -o wg0 -j ACCEPT

# Nat
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# DNS
#iptables -D INPUT -s 10.100.0.1/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
#iptables -D INPUT -s 10.100.0.1/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT

# Ignore if port forwarding is is already configured in the router
# upnpc -d 51820 udp
