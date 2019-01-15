#!/bin/bash

if [ "$1" = "vpn" ]; then
    iptables-restore < /home/slu/.config/iptables/vpn-kill.ipv4.rules
    ip6tables-restore < /home/slu/.config/iptables/vpn-kill.ipv6.rules
    echo "Network traffic is only allowed over VPN!"
else
    iptables-restore < /home/slu/.config/iptables/default.ipv4.rules
    ip6tables-restore < /home/slu/.config/iptables/default.ipv6.rules
    echo "Network traffic is unrestricted!"
fi
