#!/bin/bash

################################################
## Installation script for device «cryptopad» ##
## ------------------------------------------ ##
##   Author: Sandro Lutz <code@temparus.ch>   ##
################################################

echo "+----------------------------------------+"
echo "| Automated Post-Installation Script     |"
echo "| -  -  -  -  -  -  -  -  -  -  -  -  -  |"
echo "| Author: Sandro Lutz <code@temparus.ch> |"
echo "+----------------------------------------+"
echo

if ! [[ $EUID -ne 0 ]]; then
  echo "Running as root not intended! Please execute as a non-root user."
  exit 1
fi

echo "Installing on device «cryptopad»."
read -r -p "Is the device correct? [Y/n] " response
response=${response,,} # tolower
if [[ $response =~ ^(no|n)$ ]]; then
  exit
fi

script_dir=$(dirname $0)

echo
echo
echo "+----------------------------------------+"
echo "* Installing dotfiles..."
python $script_dir/dotty/dotty.py -r --config $script_dir/cryptopad.user.json

echo
echo
echo "+----------------------------------------+"
echo "* Finished. Enjoy your new system!"
