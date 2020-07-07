#!/bin/bash

###############################################
## Arch Scripts Helper Files                 ##
## ----------------------------------------- ##
## Disk encryption operation for boot part.  ##
## Author: Sandro Lutz <code@temparus.ch>    ##
###############################################

source "${DIR}/.helpers_disk/00_disk.sh"

# used global variables:
# - boot_password


request_new_boot_password() {
    if [ -z $boot_password ]; then
        boot_password=""
        local boot_password_repeated="1"

        echo "For encrypting the boot partition, a password is required."
        read -p "Do you want to use the same password as for the LVM partition [Y/n]: " confirm

        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            boot_password=${boot_password}
            boot_password_repeated=${boot_password}
        fi

        while [[ "$boot_password" != "$boot_password_repeated" ]]
        do
            read -sp " > Enter password: " boot_password
            echo ""
            read -sp " > Repeat password: " boot_password_repeated
            echo ""
        done
    fi
}

request_boot_password() {
    if [ -z $boot_password ]; then
        boot_password=""

        echo "For decrypting the boot partition, a password is required."
        read -p "Do you use the same password as for the LVM partition [Y/n]: " confirm

        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            boot_password=${lvm_password}
        else
        	read -sp " > Enter password: " boot_password
            echo ""
        fi
    fi
}

create_encrypted_boot_partition() {
    request_new_boot_password
    task "Set up encryption for boot partition" create_encrypted_boot_partition_cryptsetup
}

create_encrypted_boot_partition_cryptsetup() {
    request_efi_partition
    request_new_boot_partition
    # Format EFI partition as fat32 
    mkfs.fat -F32 "/dev/${efi_partition}"
    # Configure encryption for boot partition and format as ext4
    echo "${boot_password}" | cryptsetup -q luksFormat --type luks1 "/dev/${boot_partition}"
    decrypt_boot_partition
    mkfs.ext4 "/dev/mapper/${CRYPT_MAPPER_BOOT}"
    mount_efi_boot_partitions
}

decrypt_boot_partition() {
    request_boot_partition
    request_boot_password
    echo "${boot_password}" | cryptsetup open "/dev/${boot_partition}" "${CRYPT_MAPPER_BOOT}"

    if [ $? -ne 0 ]; then
        printf "\n${RED}ERROR${NC} Failed to decrypt boot partition. Please try again.\n\n"
        unset boot_password
    fi
}
