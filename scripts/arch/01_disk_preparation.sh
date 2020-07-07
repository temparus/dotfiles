#!/bin/bash

############################################
##   Installation script for Arch Linux   ##
## -------------------------------------- ##
## Chapter: Disk Preparation              ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

# Relative path from the working directory to the script location.
DIR=$(dirname "${BASH_SOURCE[0]}")

source "${DIR}/../helpers.sh"
source "${DIR}/.helpers_disk/00_disk.sh"
source "${DIR}/.helpers_disk/01_disk_lvm_partition.sh"
source "${DIR}/.helpers_disk/02_disk_boot_partition.sh"


# Functions
create_partitions() {
    # Partitions:
    # * efi:  fat32, size: ~32MiB
    # * boot:  ext4, size: 550MiB
    # * lvm:   ----, size: 100%FREE
    parted --script /dev/$disk mklabel gpt
    parted --script /dev/$disk mkpart "efi" fat32 2048s 34MiB
    parted --script /dev/$disk mkpart "boot" ext4 34MiB 584MiB
    parted --script /dev/$disk mkpart "lvm" ext4 584MiB 100%

    request_partitions
}

ask_create_swap() {
    read -p "Do you need a swap partition? [Y/n]: " confirm
    if [[ $confirm == [nN] || $confirm == [nN][oO] ]]; then
        no_swap="y"
    else
        unset no_swap
    fi
}

ask_root_fs_type() {
    read -p "Which file system do you want for the root partition? [BTRFS/ext4]: " fs_type
    if [[ "$fs_type" == "ext4" ]]; then
        root_partition_type="ext4"
    else
        root_partition_type="btrfs"
    fi
}

create_volumes() {
    # Calculate SWAP size = 1.2 * memory size
    local mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local swap_size="$(($mem * 12 / 10))K"

    pvcreate "/dev/mapper/${CRYPT_MAPPER_LVM}"
    vgcreate $LVM_VOL_GROUP "/dev/mapper/${CRYPT_MAPPER_LVM}"

    if [ -z $no_swap ]; then
        lvcreate -L $swap_size $LVM_VOL_GROUP -n swap
        mkswap "/dev/mapper/${LVM_VOL_GROUP}-swap"
    fi

    lvcreate -l 100%FREE $LVM_VOL_GROUP -n root
    if [[ "$root_partition_type" == "btrfs" ]]; then
        mkfs.btrfs -L arch "/dev/mapper/${LVM_VOL_GROUP}-root"
        mkdir -p /mnt/btrfs
        mount -t btrfs "/dev/mapper/${LVM_VOL_GROUP}-root" /mnt/btrfs
        cd /mnt/btrfs
        btrfs subvolume create home
        btrfs subvolume create root
        btrfs subvolume create snapshots
        mkdir -p ./root/var
        btrfs subvolume create ./root/var/log
        btrfs subvolume create ./root/var/tmp
        btrfs subvolume create ./root/var/cache
        umount /mnt/btrfs
        rmdir /mnt/btrfs
    else
        mkfs.ext4 "/dev/mapper/${LVM_VOL_GROUP}-root"
    fi

    mount_lvm_volumes
}

install_key_file_for_initramfs() {
    request_boot_password
    request_boot_partition
    mkdir -p /mnt/etc
    dd bs=512 count=4 if=/dev/urandom of=/mnt/etc/cryptboot_keyfile.bin
    chmod 000 /mnt/etc/cryptboot_keyfile.bin
    echo "${boot_password}" | cryptsetup luksAddKey "/dev/${boot_partition}" /mnt/etc/cryptboot_keyfile.bin
}

echo "=================================="
echo -e "Step 01: Disk Preparation\n"

echo "This setup will configure a LVM on LUKS (root (ext4 or btrfs) and swap partition)"
echo -e "and a LUKS encrypted boot partition.\n"

confirm " > Do you want to partition your disk?" 0

request_disk
task "Creating partitions" create_partitions
create_encrypted_lvm_partition
ask_create_swap
ask_root_fs_type
task "Creating LVM volumes" create_volumes
create_encrypted_boot_partition
task "Installing a keyfile for initramfs" install_key_file_for_initramfs
