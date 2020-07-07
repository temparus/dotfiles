#!/bin/bash

###############################################
## Mount encrypted partitions for Arch Linux ##
## ----------------------------------------- ##
## Mount partitions for troubleshooting      ##
## Author: Sandro Lutz <code@temparus.ch>    ##
###############################################

# Relative path from the working directory to the script location.
DIR=$(dirname "${BASH_SOURCE[0]}")

source "${DIR}/../helpers.sh"
source "${DIR}/.helpers_disk/00_disk.sh"
source "${DIR}/.helpers_disk/01_disk_lvm_partition.sh"
source "${DIR}/.helpers_disk/02_disk_boot_partition.sh"

echo "=================================="
echo -e "Special: Mount encrypted drives\n"

printf "${YELLOW}ATTENTION${NC}: Have vour passwords and YubiKey ready.\n"

request_disk
ask_lvm_encryption_type
decrypt_lvm_partition
decrypt_boot_partition
task "Mounting partitions" mount_partitions
