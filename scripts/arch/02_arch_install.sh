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
    pacstrap /mnt vim git sudo man-db man-pages iproute2 networkmanager \
                  btrfs-progs exfat-utils ntfs-3g docker \
                  pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-zeroconf pavucontrol
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
    mkdir -p /mnt/home/arch/.helpers_disk
    cp "${DIR}/03_arch_config.sh" /mnt/home/arch
    cp "${DIR}/../helper.sh" /mnt/home
    cp "${DIR}/.helpers_disk/00_disk.sh" /mnt/home/arch/.helpers_disk
}

install_key_file_for_initramfs() {
    request_boot_password
    request_boot_partition
    mkdir -p /mnt/etc
    dd bs=512 count=4 if=/dev/urandom of=/mnt/etc/cryptboot_keyfile.bin
    chmod 000 /mnt/etc/cryptboot_keyfile.bin
    echo "${boot_password}" | cryptsetup luksAddKey "/dev/${boot_partition}" /mnt/etc/cryptboot_keyfile.bin

    # Add cryptboot with stored key file to /etc/crypttab
    echo "cryptboot    UUID=${boot_partition_uuid}    /etc/cryptboot_keyfile.bin" >> /etc/crypttab
}

copy_files() {
    copy_encryption_toolset_config
    copy_arch_config_script
}

echo "=================================="
echo -e "Step 02: Arch Linux Installation\n"

task "Installing the base system" install_base_system
generate_fstab
install_key_file_for_initramfs
task "Copy files to /mnt/home" copy_files
