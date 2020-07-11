#!/bin/bash

############################################
##   Installation script for Arch Linux   ##
## -------------------------------------- ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

# Relative path from the working directory to the script location.
DIR=$(dirname "${BASH_SOURCE[0]}")

source "${DIR}/../helpers.sh"

clear_logfile

printf "Welcome to the installation script for ${UNDERLINE}${BOLD}Arch Linux${NC}\n\n"

task "Updating local clock" timedatectl set-ntp true

set -e
source "${DIR}/01_disk_preparation.sh"
source "${DIR}/02_arch_install.sh"
arch-chroot /mnt /usr/bin/bash -c /home/arch/03_arch_config.sh
source "${DIR}/04_arch_cleanup.sh"
