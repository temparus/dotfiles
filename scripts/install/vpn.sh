#!/bin/bash

############################################
##      Installation script for VPN       ##
## -------------------------------------- ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

add_keyword () {
    if ! grep -q "$1" "/etc/portage/package.accept_keywords"; then
        echo "$1" >> /etc/portage/package.accept_keywords
    fi
}

add_use_flags () {
    if ! grep -q "$1/$2" "/etc/portage/package.use/$1"; then
        echo "$1/$2 $3" >> "/etc/portage/package.use/$1"
    fi
}

emerge -v --autounmask-continue y \
        net-vpn/openvpn \
        net-vpn/vpnc \
        unzip \
        wget \
        pip

HOME=/root
echo "export PATH=\"/root/.local/bin:\$PATH\"" >> /root/.bashrc

# Install openpyn-nordvpn
python3 -m pip install --user --upgrade openpyn
/root/.local/bin/openpyn --init --silent

echo "PROFILE=\"ch\"" > /etc/vpn.conf
