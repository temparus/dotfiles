#!/bin/bash

###############################################
## Arch Scripts Helper Files                 ##
## ----------------------------------------- ##
## Disk encryption operation for LVM part.   ##
## Author: Sandro Lutz <code@temparus.ch>    ##
###############################################

source "${DIR}/../helpers.sh"
source "${DIR}/.helpers_disk/00_disk.sh"

# used global variables:
# - lvm_password

install_yubikey_encryption_toolset() {
    # Install yubikey specific crypto software
    pacman --noconfirm -Sy yubikey-manager yubikey-personalization pcsc-tools libu2f-host make cryptsetup
    systemctl start pcscd.service
    curl -L https://github.com/temparus/yubikey-full-disk-encryption/archive/master.zip | bsdtar -xvf - -C .
    cd yubikey-full-disk-encryption-master
    make install
    cd ..
    rm -r yubikey-full-disk-encryption-master

    # Update configuration file
    sed -i "s/#YKFDE_CHALLENGE_PASSWORD_NEEDED=\"1\"/YKFDE_CHALLENGE_PASSWORD_NEEDED=\"1\"/g" /etc/ykfde.conf
    sed -i "s/#YKFDE_CHALLENGE_SLOT=\"2\"/YKFDE_CHALLENGE_SLOT=\"2\"/g" /etc/ykfde.conf
}

ask_lvm_encryption_type() {
    read -p "Use a YubiKey as 2nd factor for your LVM partition? [Y/n]: " confirm
    if [[ ! $confirm == [nN] ]]; then
        lvm_partition_yubikey="y"
    else
        unset lvm_partition_yubikey
    fi
}

request_new_lvm_password() {
    if [ -z $lvm_password ]; then
        lvm_password=""
        local lvm_password_repeated="1"

        echo "For encrypting the LVM partition, a password is required."

        while [[ "$lvm_password" != "$lvm_password_repeated" ]]
        do
            read -rsp " > Enter password: " lvm_password
            echo ""
            read -rsp " > Repeat password: " lvm_password_repeated
            echo ""
        done
    fi
}

request_lvm_password() {
    if [ -z $lvm_password ]; then
        echo "For decrypting the LVM partition, a password is required."

        read -rsp " > Enter password: " lvm_password
        echo ""
    fi
}

create_encrypted_lvm_partition() {
    ask_lvm_encryption_type
    request_lvm_partition
    request_new_lvm_password

    if [ -z $lvm_partition_yubikey ]; then
        create_encrypted_normal_lvm_partition
    else
        create_encrypted_yubikey_lvm_partition
    fi
}

create_encrypted_normal_lvm_partition() {
    # Create encrypted LVM partition with Yubikey as 2nd factor
    set -e
    lvm_partition="${partitions[${#partitions[@]} - 1]}"
    echo 
    echo "${lvm_password}" | cryptsetup -q luksFormat --type luks1 "/dev/${lvm_partition}"
    echo -e "\nTrying to decrypt the LVM encrypted partition now.\n"
    decrypt_normal_lvm_partition
    set +e
}

create_encrypted_yubikey_lvm_partition() {
    if [ ! -e /usr/bin/ykfde-format ]; then
        task "Installing disk encryption toolset" install_yubikey_encryption_toolset
    fi

    printf "\n${YELLOW}ATTENTION${NC}: Have the YubiKey ready.\n\n"
    printf "You should have ${UNDERLINE}at least TWO${NC} YubiKeys\n"
    printf "with the same Challenge-Response secret for slot 2!\n\n"

    read -sp " = Press ENTER to continue. = "
    printf "\n\n"

    # Add challenge to configuration file
    # This allows a hybrid approach for decrypting the root partition:
    #  - When the boot partition is decrypted, the stored challenge
    #    can be used to decrypt the root partition (1FA).
    #    The password was already provided for unlocking the boot
    #    partition (if the same passphrase is used only!)
    #  - When directly decrypting the root partition, the password
    #    to build the challenge is also required (2FA).
    ykfde_challenge=$(printf %s "$lvm_password" | sha256sum | awk '{print $1}')
    sed -i "s/#YKFDE_CHALLENGE=\".*\"/YKFDE_CHALLENGE=\"$ykfde_challenge\"/g" /etc/ykfde.conf

    # Create encrypted LVM partition with Yubikey as 2nd factor
    set -e
    echo -e "${lvm_password}\n${lvm_password}" | ykfde-format --cipher aes-xts-plain64 --key-size 512 --hash sha256 --iter-time 5000 --type luks2 "/dev/${lvm_partition}"
    decrypt_yubikey_lvm_partition
    set +e
}

decrypt_lvm_partition() {
    if [ -z $lvm_partition_yubikey ]; then
        decrypt_normal_lvm_partition
    else
        decrypt_yubikey_lvm_partition
    fi

    if [ $? -ne 0 ]; then
        printf "\n${RED}ERROR${NC} Failed to decrypt lvm partition. Please try again.\n\n"
        unset lvm_password
        decrypt_lvm_partition
    fi
}

decrypt_normal_lvm_partition() {
    request_lvm_partition
    request_lvm_password
    echo "${lvm_password}" | cryptsetup open "/dev/${lvm_partition}" "${CRYPT_MAPPER_BOOT}"
}

decrypt_yubikey_lvm_partition() {
    if [ ! -e /usr/bin/ykfde-open ]; then
        task "Installing disk encryption toolset" install_yubikey_encryption_toolset
    fi

    request_lvm_partition
    source /etc/ykfde.conf
    if [ -z YKFDE_CHALLENGE ]; then
        request_lvm_password
        echo "${lvm_password}" | ykfde-open -d "/dev/${lvm_partition}" -n "${CRYPT_MAPPER_LVM}"
    else
        ykfde-open -d "/dev/${lvm_partition}" -n "${CRYPT_MAPPER_LVM}"
    fi
}
