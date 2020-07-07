#!/bin/bash

###############################################
## Mount encrypted partitions for Arch Linux ##
## ----------------------------------------- ##
## Unmount partitions                        ##
## Author: Sandro Lutz <code@temparus.ch>    ##
###############################################

# Relative path from the working directory to the script location.
DIR=$(dirname "${BASH_SOURCE[0]}")

source "${DIR}/../helpers.sh"
source "${DIR}/.helpers_disk/00_disk.sh"
source "${DIR}/.helpers_disk/01_disk_lvm_partition.sh"
source "${DIR}/.helpers_disk/02_disk_boot_partition.sh"

echo "=================================="
echo -e "Special: Unmount all drives\n"

request_disk
task "Mounting partitions" unmount_partitions
