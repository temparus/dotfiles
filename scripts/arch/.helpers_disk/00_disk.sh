#!/bin/bash

###############################################
## Arch Scripts Helper Files                 ##
## ----------------------------------------- ##
## Common disk configuration values          ##
## Author: Sandro Lutz <code@temparus.ch>    ##
###############################################

source "${DIR}/../helpers.sh"

CRYPT_MAPPER_BOOT="cryptboot"
CRYPT_MAPPER_LVM="cryptlvm"

LVM_VOL_GROUP="ArchVolGroup"

# used global variables:
# - disk
# - partitions
# - boot_partition
# - boot_partition_uuid
# - efi_partition
# - efi_partition_uuid
# - lvm_partition
# - lvm_partition_yubikey
# - lvm_partition_uuid
# - root_partition_type
# - root_partition_uuid
# - swap_partition_uuid
# - no_swap

# Stores the disk identifier in the variable "disk"
request_disk() {
    if [ -z $disk ]; then
        # Get all available disks
        disks=($(lsblk -l | sed -n 's/\([^ ]*\).* disk.*/\1/p'))

        echo ""
        for i in "${!disks[@]}"; do 
            printf "   %s) %s\n" "$i" "${disks[$i]}"
            last_index=$i
        done

        while [ -z $disk ]; do
            read -p " > Select disk [0-${last_index}]: " disk_index
            disk=${disks[$disk_index]}
        done
    fi
}

request_lvm_partition() {
    request_disk   
    local lvm_partition_data=($(request_partition "lvm"))

    if [ -z $lvm_partition_data ]; then
        printf "${RED}ERROR${NC}: LVM partition not found on disk ${disk}!\n"
        exit 1
    fi

    lvm_partition="${lvm_partition_data[0]}"
    lvm_partition_uuid="${lvm_partition_data[1]}"
}

request_boot_partition() {
    request_disk   
    local boot_partition_data=($(request_partition "boot"))

    if [ -z $lvm_partition_data ]; then
        printf "${RED}ERROR${NC}: Boot partition not found on disk ${disk}!\n"
        exit 1
    fi

    boot_partition="${boot_partition_data[0]}"
    boot_partition_uuid="${boot_partition_data[1]}"
}

request_efi_partition() {
    request_disk   
    local efi_partition_data=($(request_partition "efi"))

    if [ -z $lvm_partition_data ]; then
        printf "${RED}ERROR${NC}: EFI partition not found on disk ${disk}!\n"
        exit 1
    fi

    efi_partition="${efi_partition_data[0]}"
    efi_partition_uuid="${efi_partition_data[1]}"
}

request_root_partition() {
    request_disk   
    root_partition_data=($(request_lvm_volume "root"))

    if [ -z $root_partition_uuid ]; then
        printf "${RED}ERROR${NC}: root partition not found on LVM Volume ${LVM_VOL_GROUP}!\n"
        exit 1
    fi

    root_partition_uuid="${root_partition_data[0]}"
    root_partition_type="${root_partition_data[1]}"
}

request_swap_partition() {
    request_disk   
    swap_partition_data=($(request_lvm_volume "swap"))
    swap_partition_uuid="${swap_partition_data[0]}"

    if [ -z $swap_partition_uuid ]; then
        printf "${YELLOW}WARNING${NC}: Swap partition not found on LVM Volume ${LVM_VOL_GROUP}!\n"
        no_swap="y"
    else
        unset no_swap
    fi
}

request_partitions() {
    request_efi_partition
    request_boot_partition
    request_lvm_partition
}

mount_partitions() {
    mount_lvm_volumes
    mount_efi_boot_partitions
}

mount_lvm_volumes() {
    if [ root_partition_type == "btrfs" ]; then
        mount -o noatime,ssd,compress=lzo subvol=/root "/dev/mapper/${LVM_VOL_GROUP}-root" /mnt
        mkdir -p /mnt/home
        mount -o noatime,ssd,compress=lzo subvol=/home "/dev/mapper/${LVM_VOL_GROUP}-root" /mnt/home
        mkdir -p /mnt/var/log
        mount -o nodatacow,noatime,ssd,compress=lzo subvol=/var/log "/dev/mapper/${LVM_VOL_GROUP}-root" /mnt/var/log
        mkdir -p /mnt/var/cache
        mount -o nodatacow,noatime,ssd,compress=lzo subvol=/var/cache "/dev/mapper/${LVM_VOL_GROUP}-root" /mnt/var/cache
        mkdir -p /mnt/var/tmp
        mount -o nodatacow,noatime,ssd,compress=lzo subvol=/var/tmp "/dev/mapper/${LVM_VOL_GROUP}-root" /mnt/var/tmp
        mkdir -p /mnt/.snapshots
        mount -o noatime,ssd,compress=lzo subvol=/snapshots "/dev/mapper/${LVM_VOL_GROUP}-root" /mnt/.snapshots
    else
        mount "/dev/mapper/${LVM_VOL_GROUP}-root" /mnt
    fi

    if [ -z $no_swap ]; then
        swapon "/dev/mapper/${LVM_VOL_GROUP}-swap"
    fi
}

mount_efi_boot_partitions() {
    request_efi_partition
    mkdir -p /mnt/boot
    mount "/dev/mapper/${CRYPT_MAPPER_BOOT}" /mnt/boot
    mkdir -p /mnt/boot/efi
    mount "/dev/${efi_partition}" /mnt/boot/efi
}


# Private functions below
request_partition() {
    blkid -t PARTLABEL="${1}" | sed -n "/\/dev\/${disk}/s/\/dev\/\([^:]*\).* UUID=\"\([^\"]*\)\".*/\1 \2/p"
}

request_lvm_volume() {
    blkid | sed -n "/\/dev\/mapper\/${LVM_VOL_GROUP}-${1}/s/.* UUID=\"\([^\"]*\)\".* TYPE=\"\([^\"]*\)\".*/\1 \2/p"
}
