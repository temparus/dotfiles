#!/bin/bash

###############################################
## Mount encrypted partitions for Arch Linux ##
## ----------------------------------------- ##
## Mount partitions for troubleshooting      ##
## Author: Sandro Lutz <code@temparus.ch>    ##
###############################################

source ../helpers.sh

# Static configuration options
vol_group="ArchVolGroup"

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

decrypt_partitions() {
    set -e
    lvm_partition="${partitions[${#partitions[@]} - 1]}"
    ykfde-open -d "/dev/${lvm_partition}" -n cryptlvm
    cryptsetup open "/dev/${partitions[1]}" cryptboot
    set +e
}

mount_partitions() {
    mount "/dev/${vol_group}-root" /mnt
    mount /dev/mapper/cryptboot /mnt/boot
    mount "/dev/${partitions[2]}" /mnt/boot/efi
    swapon "/dev/${vol_group}-swap"
}


echo "=================================="
echo -e "Special: Mount encrypted drives\n"

printf "${ORANGE}ATTENTION${NC}: Have vour passwords and YubiKey ready.\n"

task "Installing disk encryption toolset" install_encryption_toolset
select_disk
decrypt_partitions
mount_partitions
