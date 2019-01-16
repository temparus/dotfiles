#!/bin/bash

# Reload VPN services when connected to a WiFi network.

case "$2" in
    CONNECTED)
        echo "WPA supplicant: connection established";
        sleep 5s
	! /usr/bin/killall -SIGHUP openvpn
        if /usr/bin/killall -SIGTERM vpnc; then
            /usrsbin/vpnc eth
        fi
        ;;
    DISCONNECTED)
        echo "WPA supplicant: connection lost";
        ;;
esac
