#! /bin/bash

PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`

if pgrep -x vpnc > /dev/null; then
    echo "%{F#aaff77}  (ETH)%{F-}  $PUBLIC_IP "
elif pgrep -x openvpn > /dev/null; then
    echo "%{F#aaff77}  (NordVPN)%{F-}  $PUBLIC_IP"
else
    echo "%{F#ff5555}  (insecure)%{F-}  $PUBLIC_IP"
fi
