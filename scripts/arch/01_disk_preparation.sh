#!/bin/bash

############################################
##   Installation script for Arch Linux   ##
## -------------------------------------- ##
## Chapter: Disk Preparation              ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

source ../helpers.sh

# Static configuration options
vol_group="ArchVolGroup"

# Functions
create_partitions() {
    local disk=$1

    # Partitions:
    # * efi:  fat32, size: ~32MiB
    # * boot:  ext4, size: 550MiB
    # * lvm:   ----, size: 100%FREE
    parted --script /dev/$disk mklabel gpt
    parted --script /dev/$disk mkpart "efi" fat32 2048s 34MiB
    parted --script /dev/$disk mkpart "boot" ext4 34MiB 584MiB
    parted --script /dev/$disk mkpart "lvm" ext4 582MiB 100%
}

install_encryption_toolset() {
    # Install yubikey specific crypto software
    pacman -Sy yubikey-manager yubikey-personalization pcsc-tools libu2f-host make cryptsetup
    systemctl start pcscd.service
    curl -L https://github.com/agherzan/yubikey-full-disk-encryption/archive/master.zip | bsdtar -xvf - -C .
    cd yubikey-full-disk-encryption-master
    make install
    cd ..
    rm -r yubikey-full-disk-encryption-master

    # Update configuration file
    sed -i "s/#YKFDE_CHALLENGE_PASSWORD_NEEDED=\"1\"/YKFDE_CHALLENGE_PASSWORD_NEEDED=\"1\"/g" /etc/ykfde.conf
    sed -i "s/#YKFDE_CHALLENGE_SLOT=\"2\"/YKFDE_CHALLENGE_SLOT=\"2\"/g" /etc/ykfde.conf
}

create_volumes() {
    # Calculate SWAP size = 1.5 * memory size
    local mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local swap_size="$(($mem * 3 / 2))K"

    pvcreate /dev/mapper/cryptlvm
    vgcreate $vol_group /dev/mapper/cryptlvm

    lvcreate -L $swap_size $vol_group -n swap
    lvcreate -l 100%FREE $vol_group -n root

    mkfs.ext4 "/dev/${vol_group}-root"
    mkswap "/dev/${vol_group}-swap"

    mount "/dev/${vol_group}-root" /mnt
    swapon "/dev/${vol_group}-swap"
}

prepare_boot_partition() {
    partitions=($(lsblk -l | sed -n "s/\(${disk}[^ ]*\).* part.*/\1/p"))
    # Format EFI partition as fat32 
    mkfs.fat -F32 "/dev/${partitions[0]}"
    # Configure encryption for boot partition and format as ext4
    cryptsetup luksFormat --type luks1 "/dev/${partitions[1]}"
    cryptsetup open "/dev/${partitions[1]}" cryptboot
    mkfs.ext4 /dev/mapper/cryptboot
    # Mount boot partition
    mkdir /mnt/boot
    mount /dev/mapper/cryptboot /mnt/boot
    # Mount EFI partition
    mkdir /mnt/boot/efi
    mount "/dev/${partitions[2]}" /mnt/boot/efi
}

install_key_file_for_initramfs() {
    dd bs=512 count=4 if=/dev/urandom of=/mnt/crypto_keyfile.bin
    chmod 000 /mnt/crypto_keyfile.bin
    cryptsetup luksAddKey "/dev/${partitions[1]}" /mnt/crypto_keyfile.bin
}

echo "=================================="
echo -e "Step 01: Disk Preparation\n"

echo "This setup will configure a LVM on LUKS (root and swap partition)"
echo -e "and a LUKS encrypted boot partition.\n"

confirm "Do you want to partition your disks?" 0

select_disk
task "Creating partitions" create_partitions $disk
task "Installing disk encryption toolset" install_encryption_toolset

echo -e "\nMake sure that you have two YubiKeys ready\n"
echo -e "with the second slot configured as Challenge-Response\n"
echo -e "with the same secret!\n\n"

printf "${ORANGE}ATTENTION${NC}: Have the YubiKey ready.\n"

set -e
lvm_partition="${partitions[${#partitions[@]} - 1]}"
ykfde-format --cipher aes-xts-plain64 --key-size 512 --hash sha256 --iter-time 5000 --type luks2 "/dev/${lvm_partition}"
ykfde-open -d "/dev/${lvm_partition}" -n cryptlvm
set +e

lvm_password_repeated=""
lvm_password_repeated="1"

while [[ "$lvm_password" != "$lvm_password_repeated" ]]
do
    read -sp "Your LVM password: " lvm_password
    read -sp "Repeat your LVM password: " lvm_password_repeated
done

ykfde_challenge=$(printf "$lvm_password" | sha256sum | awk '{print $1}')
sed -i "s/#YKFDE_CHALLENGE=\"/YKFDE_CHALLENGE=\"$ykfde_challenge/g" /etc/ykfde.conf

task "Creating LVM volumes" create_volumes
prepare_boot_partition
task "Installing a keyfile for initramfs" install_key_file_for_initramfs
