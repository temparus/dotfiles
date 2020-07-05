#!/bin/bash

############################################
##   Installation script for Arch Linux   ##
## -------------------------------------- ##
## Chapter: Arch Linux Configuration      ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

# ATTENTION! This file must be executed within a chroot environment!

source ../helpers.sh

# Static configuration options
vol_group="ArchVolGroup"

# Functions
select_disk() {
    # Get all available disks
    disks=($(lsblk -l | sed -n 's/\([^ ]*\).* disk.*/\1/p'))

    PS3="Enter a number to select a disk: "

    select disk in $disks
    do
        if [[ $disk ]]; then
            break
        fi
    done
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

    # Copy configuration file
    cp /home/ykfde.conf /etc/ykfde.conf
}

configure_timezone() {
    timezone=""

    while [[ ! -f "/usr/share/zoneinfo/${timezone}" ]]
    do
        read -sp "Enter timezone (e.g. Europe/Zurich): " timezone
    done
    ls -sf "/usr/share/zoneinfo/${timezone}" /etc/localtime
    hwclock --systohc
}

configure_locales() {
    echo "Uncomment all locales which should be generated in the following file."
    read -sp "Press ANY key to continue." unused_input

    vim /etc/locale.gen

    locale-gen
    read -p "Enter the system default locale (e.g. en_US.UTF-8): " default_locale
    echo "LANG=${default_locale}" > /etc/locale.conf
}

configure_hostname() {
    read -p "Enter desired hostname: " hostname

    echo "${hostname}" > /etc/hostname

    echo "127.0.0.1          localhost" >> /etc/hosts
    echo "::1                localhost" >> /etc/hosts
    echo "127.0.1.1          ${hostname}.localdomain ${hostname}" >> /etc/hosts
}

rebuild_initramfs() {
    sed -i "s/MODULES=.*/MODULES=(ext4)/g" /etc/mkinitcpio.conf
    sed -i "s/HOOKS=.*/HOOKS=(base udev autodetect modconf block keymap lvm2 filesystems fsck keyboard ykfde)/g" /etc/mkinitcpio.conf
    mkinitcpio -P
}

install_grub_bootloader() {
    pacman -Sy grub

    partitions=($(lsblk -l | sed -n "s/\(${disk}[^ ]*\).* part.*/\1/p"))
    lvm_uuid=$(blkid | sed -n "/\/dev\/${partitions[${#partitions[@]} - 1]}/s/.* UUID=\"\([^\"]*\)\".*/\1/p")
    root_uuid=$(blkid | sed -n "/\/dev\/mapper\/${vol_group}-root/s/.* UUID=\"\([^\"]*\)\".*/\1/p")
    swap_uuid=$(blkid | sed -n "/\/dev\/mapper\/${vol_group}-swap/s/.* UUID=\"\([^\"]*\)\".*/\1/p")

    echo "GRUB_CMDLINE_LINUX=\"UUID=${lvm_uuid}:cryptlvm root=UUID=${root_uuid} resume=UUID=${swap_uuid}\"" >> /etc/default/grub
    echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub

    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch --recheck
    grub-mkconfig -o /boot/grub/grub.cfg

    sed -i "s/#YKFDE_LUKS_NAME=\".*\"/YKFDE_LUKS_NAME=\"cryptlvm\"/g" /etc/ykfde.conf
    sed -i "s/#YKFDE_DISK_UUID=\".*\"/YKFDE_DISK_UUID=\"${lvm_uuid}\"/g" /etc/ykfde.conf
}

create_admin_user() {
    echo "We create the first administrator user account now."
    read -p "Enter username: " username

    useradd -m $username
    passwd $username
    groupadd sudo
    usermod -a -G sudo $username
    sed -i "s/# %sudo .*/%sudo ALL=(ALL) ALL/g" /etc/sudoers
}

configure_secure_boot() {
    pacman -Sy binutils fakeroot
    sudo -u nobody curl -L https://github.com/xmikos/cryptboot/archive/master.zip | bsdtar -xvf - -C .
    sudo -u nobody /bin/bash -c "cd cryptboot-master && makepkg --skipchecksums"
    rm -r cryptboot-master

    cryptboot-efikeys create
    cryptboot-efikeys enroll
    cryptboot update-grub

    # Install pacman hook
    {
        echo "[Trigger]"
        echo "Operation = Install"
        echo "Operation = Upgrade"
        echo "Type = Package"
        echo "Target = linux"
        echo ""
        echo "[Action]"
        echo "Description = Signing Kernel for SecureBoot - Update GRUB"
        echo "When = PostTransaction"
        echo "Exec = /usr/bin/cryptboot update-grub"
    } > /etc/pacman.d/hooks/98-secureboot.hook
}

install_yay() {
    read -p "Do you want to install Yet Another Yoghurt (AUR helper) [y/N]: " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        pacman --noconfirm -Sy fakeroot binutils make sudo git pkgconf go
        sudo -u nobody git clone https://aur.archlinux.org/yay.git /tmp/yay
        sudo -u nobody /bin/bash -c "cd /tmp/yay && makepkg"
        rm -r /tmp/yay
    fi
}


# Relative path from the working directory to the script location.
DIR=$(dirname "${BASH_SOURCE[0]}")

echo "=================================="
echo -e "Step 03: Arch Linux Configuration\n"

select_disk
task "Installing encryption toolset" install_encryption_toolset
configure_timezone
configure_locales
configure_hostname
task "Rebuilding initramfs" rebuild_initramfs
task "Installing grub bootloader" install_grub_bootloader
configure_secure_boot
install_yay
create_admin_user
