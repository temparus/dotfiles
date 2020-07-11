#!/bin/bash

############################################
##   Installation script for Arch Linux   ##
## -------------------------------------- ##
## Chapter: Arch Linux Configuration      ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

# ATTENTION! This file must be executed within a chroot environment!

# Relative path from the working directory to the script location.
DIR=$(dirname "${BASH_SOURCE[0]}")

source "${DIR}/../helpers.sh"
source "${DIR}/.helpers_disk/00_disk.sh"


# Functions
install_encryption_toolset() {
    # Install yubikey specific crypto software
    pacman --noconfirm -Sy yubikey-manager yubikey-personalization pcsc-tools libu2f-host make cryptsetup
    systemctl start pcscd.service
    curl -L https://github.com/temparus/yubikey-full-disk-encryption/archive/master.zip | bsdtar -xvf - -C .
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
        read -p "Enter timezone (e.g. Europe/Zurich): " timezone
    done
    ln -sf "/usr/share/zoneinfo/${timezone}" /etc/localtime
    hwclock --systohc
}

configure_locales() {
    echo "Uncomment all locales which should be generated in the following file."
    read -sp "Press ENTER to continue." unused_input

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
    sed -i "s/HOOKS=.*/HOOKS=(base udev autodetect modconf block keymap lvm2 filesystems fsck keyboard ykfde resume)/g" /etc/mkinitcpio.conf
    mkinitcpio -P
}

install_grub_bootloader() {
    request_disk
    request_lvm_partition
    request_root_partition
    request_swap_partition

    pacman --noconfirm -Sy grub

    if [ -z $no_swap ]; then
        echo "GRUB_CMDLINE_LINUX=\"UUID=${lvm_partition_uuid}:cryptlvm root=UUID=${root_partition_uuid} resume=UUID=${swap_partition_uuid}\"" >> /etc/default/grub
    else
        echo "GRUB_CMDLINE_LINUX=\"UUID=${lvm_partition_uuid}:cryptlvm root=UUID=${root_partition_uuid}\"" >> /etc/default/grub
    fi
    echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub

    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch --recheck
    grub-mkconfig -o /boot/grub/grub.cfg

    if [ -e /etc/ykfde.conf ]; then
        sed -i "s/#YKFDE_LUKS_NAME=\".*\"/YKFDE_LUKS_NAME=\"cryptlvm\"/g" /etc/ykfde.conf
        sed -i "s/#YKFDE_DISK_UUID=\".*\"/YKFDE_DISK_UUID=\"${lvm_uuid}\"/g" /etc/ykfde.conf
    fi
}

install_bluetooth() {
    pacman --noconfirm -S bluez bluez-utils
    systemctl enable bluetooth
}

create_admin_user() {
    echo "We create the first administrator user account now."
    read -p "Enter username: " username

    useradd -m $username
    passwd $username
    groupadd sudo
    usermod -a -G sudo $username
    sed -i "s/#\ %sudo.*/%sudo ALL=(ALL) ALL/g" /etc/sudoers
}

configure_secure_boot() {
    request_boot_partition

    pacman --noconfirm -Sy binutils fakeroot efitools sbsigntools
    sudo -u nobody /usr/bin/bash -c "curl -L https://github.com/xmikos/cryptboot/archive/master.zip | bsdtar -xvf - -C /tmp"
    sudo -u nobody /usr/bin/bash -c "cd /tmp/cryptboot-master && makepkg --skipchecksums"
    pacman -U /tmp/cryptboot-master/cryptboot*.pkg.tar.xz
    rm -r /tmp/cryptboot-master

    sed -i "s/EFI_ID_GRUB=\".*\"/EFI_ID_GRUB=\"arch\"/g" /etc/cryptboot.conf
    sed -i "s/EFI_PATH_GRUB=\".*\"/EFI_PATH_GRUB=\"EFI/arch/grubx64.efi\"/g" /etc/cryptboot.conf

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
        sudo -u nobody /usr/bin/bash -c "git clone https://aur.archlinux.org/yay.git /tmp/yay"
        sudo -u nobody /usr/bin/bash -c "cd /tmp/yay && makepkg"
        pacman -U /tmp/yay/yay*.pkg.tar.xz
        rm -r /tmp/yay
    fi
}

echo "=================================="
echo -e "Step 03: Arch Linux Configuration\n"

select_disk
task "Installing encryption toolset" install_encryption_toolset
configure_timezone
configure_locales
configure_hostname
task "Rebuilding initramfs" rebuild_initramfs
task "Installing grub bootloader" install_grub_bootloader
task "Installing bluetooth packages" install_bluetooth
configure_secure_boot
install_yay
create_admin_user
