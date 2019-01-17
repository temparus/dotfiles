#!/bin/bash

if [[ $EUID > 0 ]]; then
  echo "Do run this script as root!"
  exit
fi

if [ "$1" = "vpn" ]; then
    iptables-restore < /var/lib/iptables/vpn-kill.ipv4.rules
    ip6tables-restore < /var/lib/iptables/vpn-kill.ipv6.rules
    echo "Network traffic is only allowed over VPN!"
else
    iptables-restore < /var/lib/iptables/default.ipv4.rules
    ip6tables-restore < /var/lib/iptables/default.ipv6.rules
    echo "Network traffic is unrestricted!"
fi
