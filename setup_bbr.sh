#!/bin/bash

cat << eof > /etc/modules-load.d/tcp_bbr.conf
tcp_bbr
eof

cat << eof > /etc/sysctl.d/60-bbr.conf
net.ipv4.tcp_congestion_control=bbr
eof
