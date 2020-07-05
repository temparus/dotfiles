#!/bin/bash

############################################
##   Installation script for Arch Linux   ##
## -------------------------------------- ##
## Chapter: Arch Installation             ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

# Relative path from the working directory to the script location.
DIR=$(dirname "${BASH_SOURCE[0]}")

source "${DIR}/../helpers.sh"

# Functions
install_base_system() {
    # Install base system
    pacstrap /mnt base linux linux-firmware base-devel lvm2 make dbus grub-efi-x86_64 efibootmgr
    # Install YubiKey software
    pacstrap /mnt yubikey-manager pcsc-tools cryptsetup
    # Install other basic packages
    pacstrap /mnt vim git sudo man-db man-pages iproute2 networkmanager exfat-utils ntfs-3g docker
}

generate_fstab() {
    # Generate fstab
    genfstab -U -p /mnt >> /mnt/etc/fstab

    echo "----------------------------"
    cat /mnt/etc/fstab
    echo "----------------------------"
    confirm "Does the \"fstab\" file look correct?"
}

copy_encryption_toolset_config() {
    cp /etc/ykfde.conf /mnt/home
}

copy_arch_config_script() {
    mkdir /mnt/home/arch
    cp "${DIR}/03_arch_config.sh" /mnt/home/arch
    cp "$DIR/../helper.sh" /mnt/home
}

copy_files() {
    copy_encryption_toolset_config
    copy_arch_config_script
}

echo "=================================="
echo -e "Step 02: Arch Linux Installation\n"

task "Installing the base system" install_base_system
generate_fstab
task "Copy files to /mnt/home" copy_files
