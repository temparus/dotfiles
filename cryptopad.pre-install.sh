#!/bin/bash

################################################
## Installation script for device «cryptopad» ##
## ------------------------------------------ ##
##   Author: Sandro Lutz <code@temparus.ch>   ##
################################################

echo "+----------------------------------------+"
echo "| Automated Pre-Installation Script      |"
echo "| -  -  -  -  -  -  -  -  -  -  -  -  -  |"
echo "| Author: Sandro Lutz <code@temparus.ch> |"
echo "+----------------------------------------+"
echo

if [[ $EUID > 0 ]]; then
  echo "Script must run as root user!"
  exit 1
fi

echo "Installing on device «cryptopad»."
read -r -p "Is the device correct? [Y/n] " response
response=${response,,} # tolower
if [[ $response =~ ^(no|n)$ ]]; then
  exit
fi

echo
echo
echo "+----------------------------------------+"
echo "* Installing basic portage configuration..."
python dotty/dotty.py -rf --config cryptopad.system.json

echo
echo
echo "+----------------------------------------+"
echo "* Installing basic packages..."
scripts/install/basics.sh

echo
echo
echo "+----------------------------------------+"
echo "* Installing X11..."
scripts/install/x11.sh

echo
echo
echo "+----------------------------------------+"
echo "* Installing VPN..."
scripts/install/vpn.sh

echo
echo
echo "+----------------------------------------+"
echo "* Finish the installation of the system and reboot."
echo "==> Run the Post-Installation Script (cryptopad.post-install.sh)."
