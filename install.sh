#!/bin/bash

# test lock file, run once
test -e /etc/.pi-bridge && exit 1

# install dnsmasq
apt install -y dnsmasq iptables-persistent
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

# setup interfaces
cat << eof > /etc/network/interfaces.d/eth0
allow-hotplug eth0
iface eth0 inet static
	address 10.255.255.1
	netmask 255.255.255.0
	network 10.255.255.0
	broadcast 10.255.255.255
eof

# setup dnsmasq
cat << eof > /etc/dnsmasq.conf
interface=eth0
listen-address=10.255.255.1
bind-interfaces
server=$(ip route show dev wlan0 | grep default | awk '{print $3}')  # the default gateway of wlan0 is set as the dns server
domain-needed
bogus-priv
dhcp-range=10.255.255.50,10.255.255.155,12h
eof

# setup sysctl for nat
cat << eof > /etc/sysctl.d/97-nat.conf
net.ipv4.ip_forward=1
eof

# setup iptables
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

# install lock
touch /etc/.pi-bridge
