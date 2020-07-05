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
    parted --script /dev/$disk mkpart "lvm" ext4 584MiB 100%
}

install_encryption_toolset() {
    # Install yubikey specific crypto software
    pacman --noconfirm -Sy yubikey-manager yubikey-personalization pcsc-tools libu2f-host make cryptsetup
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

    mkfs.ext4 "/dev/mapper/${vol_group}-root"
    mkswap "/dev/mapper/${vol_group}-swap"

    mount "/dev/mapper/${vol_group}-root" /mnt
    swapon "/dev/mapper/${vol_group}-swap"
}

prepare_lvm_password() {
    lvm_password=""
    local lvm_password_repeated="1"

    echo "For encrypting the LVM partition, a password is required."

    while [[ "$lvm_password" != "$lvm_password_repeated" ]]
    do
        read -sp " > Enter password: " lvm_password
        echo ""
        read -sp " > Repeat password: " lvm_password_repeated
        echo ""
    done
}

create_encrypted_lvm_partition() {
    printf "\n${YELLOW}ATTENTION${NC}: Have the YubiKey ready.\n\n"
    printf "You should have ${UNDERLINE}at least TWO${NC} YubiKeys\n"
    printf "with the same Challenge-Response secret for slot 2!\n\n"

    read -sp " = Press ENTER to continue. = "
    printf "\n\n"

    prepare_lvm_password

    # Add challenge to configuration file
    ykfde_challenge=$(printf "$lvm_password" | sha256sum | awk '{print $1}')
    sed -i "s/#YKFDE_CHALLENGE=\"/YKFDE_CHALLENGE=\"$ykfde_challenge/g" /etc/ykfde.conf

    # Create encrypted LVM partition with Yubikey as 2nd factor
    set -e
    lvm_partition="${partitions[${#partitions[@]} - 1]}"
    echo 
    echo "${lvm_password}" | ykfde-format -q --cipher aes-xts-plain64 --key-size 512 --hash sha256 --iter-time 5000 --type luks2 "/dev/${lvm_partition}"
    echo -e "\nTrying to decrypt the LVM encrypted partition now.\n"
    echo "${lvm_password}" | ykfde-open -d "/dev/${lvm_partition}" -n cryptlvm
    set +e
}

prepare_boot_password() {
    boot_password=""
    local boot_password_repeated="1"

    echo "For encrypting the boot partition, a password is required."
    read -p "Do you want to use the same password as for the LVM partition [Y/n]: " confirm

    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        boot_password=${lvm_password}
        boot_password_repeated=${boot_password}
    fi

    while [[ "$boot_password" != "$boot_password_repeated" ]]
    do
        read -sp " > Enter password: " boot_password
        echo ""
        read -sp " > Repeat password: " boot_password_repeated
        echo ""
    done
}

prepare_boot_partition() {
    partitions=($(lsblk -l | sed -n "s/\(${disk}[^ ]*\).* part.*/\1/p"))
    # Format EFI partition as fat32 
    mkfs.fat -F32 "/dev/${partitions[0]}"
    # Configure encryption for boot partition and format as ext4
    echo "${boot_password}" | cryptsetup -q luksFormat --type luks1 "/dev/${partitions[1]}"
    echo "${boot_password}" | cryptsetup open "/dev/${partitions[1]}" cryptboot
    mkfs.ext4 /dev/mapper/cryptboot
    # Mount boot partition
    mkdir /mnt/boot
    mount /dev/mapper/cryptboot /mnt/boot
    # Mount EFI partition
    mkdir /mnt/boot/efi
    mount "/dev/mapper/cryptboot" /mnt/boot/efi
}

install_key_file_for_initramfs() {
    dd bs=512 count=4 if=/dev/urandom of=/mnt/crypto_keyfile.bin
    chmod 000 /mnt/crypto_keyfile.bin
    printf "${boot_password}\n" | cryptsetup luksAddKey "/dev/${partitions[1]}" /mnt/crypto_keyfile.bin
}

echo "=================================="
echo -e "Step 01: Disk Preparation\n"

echo "This setup will configure a LVM on LUKS (root and swap partition)"
echo -e "and a LUKS encrypted boot partition.\n"

confirm " > Do you want to partition your disk?" 0

select_disk
task "Creating partitions" create_partitions $disk
task "Installing disk encryption toolset" install_encryption_toolset
create_encrypted_lvm_partition
task "Creating LVM volumes" create_volumes
prepare_boot_password
task "Set up encryption for boot partition" prepare_boot_partition
task "Installing a keyfile for initramfs" install_key_file_for_initramfs
