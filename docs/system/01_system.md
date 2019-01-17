# Gentoo System Setup Guide

This is a general system setup guide for Gentoo.
If you encounter any problems with this guide, see the [guide in the Gentoo Wiki](https://wiki.gentoo.org/wiki/Full_Disk_Encryption_From_Scratch_Simplified)

## Table of Contents

* [Create Partitions](#create-partitions)
* [Create boot filesystem](#create-boot-filesystem)
* [*(optional)* Prepare encrypted partition](#optional-prepare-encrypted-partition)
* [Format root partition](#format-root-partition)
* [Install Gentoo](#install-gentoo)
* [Configure fstab](#configure-fstab)
* [Configure the Linux Kernel](#configure-the-linux-kernel)
* [Install System Tools](#install-system-tools)
* [Install GRUB2](#install-grub2)
* [Finalizing](#finalizing)
* [Where to go from here](#where-to-go-from-here)

## Create Partitions
Partition schema is as following:
```
/dev/sdX
|--> GRUB BIOS                       2   MB       no fs       grub loader itself
|--> /boot                 boot      512 MB       fat32       grub and kernel
|--> LUKS encrypted                  100%         encrypted   encrypted binary block 
     |-->  /               root      100%         ext4        rootfs
```

Prepare the harddisk with the following commands:
```bash
parted -a optimal /dev/sdX
(parted) unit mib        # set unit to mebibyte
(parted) mklabel gpt     # set partition table to GPT
```

Create the BIOS partition:
```bash
(parted) mkpart primary 1 3
(parted) name 1 grub
(parted) set 1 bios_grub on
```

Create boot partition. This partition will contain grub files, plain (unencrypted) kernel and kernel initrd:
```bash
(parted) mkpart primary fat32 3 515
(parted) name 2 boot
(parted) set 2 BOOT on
(parted) mkpart primary 515 -1
(parted) name 3 root
```

## Create boot filesystem
Create filesystem for /dev/sdX2, that will contain grub and kernel files. This partition is read by UEFI bios. Most of motherboards can ready only FAT32 filesystems:
```bash
mkfs.vfat -F32 /dev/sdX2
```

## *(optional)* Prepare encrypted partition

In the next step, we configure DM-CRYPT for /dev/sdX3:
```bash
modprobe dm-crypt
cryptsetup luksFormat -c aes-xts-plain64:sha256 -s 256 /dev/sdX3 # create the encrypted partition
cryptsetup luksOpen /dev/sdX3 root                               # open encrypted device
```

## Format root partition

```bash
mkfs.ext4 /dev/mapper/root   # when using an encrypted partition
mkfs.ext4 /dev/sdX3          # otherwise
```

## Install Gentoo

```bash
mkdir /mnt/gentoo
mount /dev/mapper/root /mnt/gentoo     # when using an encrypted partition
mount /dev/sdX3 /mnt/gentoo            # otherwise
cd /mnt/gentoo
```

Follow the instructions in the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage).

**See the detailed instructions for the corresponding device!**

## Configure fstab

For correct setup of required partition, will be used UUID technique.

Run blkid and see partition IDs: 

```bash
blkid

/dev/sdb: PTUUID="3157e787-9d24-4c18-9309-99b31d7c361f" PTTYPE="gpt"
/dev/sdb1: UUID="9CEB-80C1" TYPE="vfat" PARTLABEL="grub" PARTUUID="5eebb27e-9201-45b4-a17a-7ec39983ce2e"
/dev/sdb2: UUID="AABD-F439" TYPE="vfat" PARTLABEL="boot" PARTUUID="daa859db-14ba-4e3c-ba0e-f3eb75768bc6"
/dev/sdb3: UUID="78536dfa-fb75-4090-93ed-110bbbb670ba" TYPE="crypto_LUKS" PARTLABEL="primary" PARTUUID="f7bcb91c-9a0b-4ce7-9acb-b058bb434609"
/dev/sda1: LABEL="UBUNTU 18_0" UUID="221E-8E32" TYPE="vfat" PARTUUID="28153003-01"
/dev/mapper/root: UUID="1aa29402-ef5d-4bae-8fbd-010b85dcc3b3" TYPE="ext4"
```

Edit /etc/fstab and setup correct filesystem:

```fstab
# <fs>                                     <mountpoint>    <type>          <opts>          <dump/pass>
UUID=AABD-F439                             /boot           vfat            noauto,noatime  1 2
UUID=1aa29402-ef5d-4bae-8fbd-010b85dcc3b3  /               ext4            defaults        0 1
# tmps
tmpfs                                      /tmp            tmpfs           size=4Gb        0 0
tmpfs                                      /run            tmpfs           size=100M       0 0
# shm
shm                                        /dev/shm        tmpfs           nodev,nosuid,noexec 0 0
```

## Configure the Linux Kernel

Install the required packages:

```bash
emerge -va sys-kernel/gentoo-sources sys-kernel/genkernel sys-fs/cryptsetup
```

Make sure to enable all required kernel options for [dm-crypt](https://wiki.gentoo.org/wiki/Dm-crypt#Kernel_Configuration).

Follow the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel) to build the kernel.

**To use the most recent kernel version from `sys-kernel/gentoo-sources`, you may run the following command before building proceeding:**

```bash
echo "sys-kernel/gentoo-sources ~amd64" >> /etc/portage/package.accept_keywords 
```

Generate an initramfs (mandatory for an encrypted root partition):

```bash
genkernel --luks --install initramfs 
```
## Install System Tools

Follow the instructions in the [Gentoo Handbook](ttps://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Tools).

## Install GRUB2

```bash
echo "sys-boot/grub:2 device-mapper" >> /etc/portage/package.use/sys-boot
emerge -av grub
```

Add the following line to the file `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX="crypt_root=UUID=78536dfa-fb75-4090-93ed-110bbbb670ba root=/dev/mapper/root root_trim=yes"
```

```bash
mount /boot
grub-install /dev/sdX                 # install bootloader in BIOS mode
grub-mkconfig -o /boot/grub/grub.cfg  # generate the GRUB2 configuration file
```

## Finalizing

Set a password for the root user:

```bash
passwd
```

Follow the instructions in the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing).

## Where to go from here

* If you are using an encrypted volume, see [dm-crypt](https://wiki.gentoo.org/wiki/Dm-crypt).

* Install the dotfiles and execute the additional installation scripts from that repository.
