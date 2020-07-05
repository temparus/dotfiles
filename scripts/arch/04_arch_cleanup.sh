#!/bin/bash

############################################
##   Installation script for Arch Linux   ##
## -------------------------------------- ##
## Chapter: Install Files Cleanup         ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

# Relative path from the working directory to the script location.
DIR=$(dirname "${BASH_SOURCE[0]}")

source "${DIR}/../helpers.sh"

# Functions
remove_arch_config_script() {
    rm -r /mnt/home/arch
    rm /mnt/home/helpers.sh
    rm ykfde.conf
}

echo "=================================="
echo -e "Step 04: Arch Linux Cleanup\n"

task "Cleaning up temporary files" remove_arch_config_script
