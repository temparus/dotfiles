# Prepare Disk

We prepare the disk for the system installation and full-disk encryption.

There are [different variants](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system) to setup encryption.

We use [LVM on LUKS](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS) for this guide.

Create the following partitions:

> TODO: add partition table.

## Prepare YubiKey

!!! note "YubiKey Preparation"
    This guide uses YubiKey as 2nd factor for the full-disk encryption.

!!! danger
    I highly recommend to have at least two YubiKeys.
    If you loose access to all of your keys, there is no way to unlock the disk anymore!
    To reduce the risk of loosing access to the encrypted disk, a normal key can be configured for LUKS in parallel. You should make sure that the key is large enough so that is does not undermine the encryption setup.

Configure the second slot of your YubiKeys for Challenge-Response. You can use the YubiKey Manager GUI application on another computer or use the CLI application `ykpersonalize`.

## Install ykfde

Download or mount [yubikey-full-disk-encryption](https://github.com/agherzan/yubikey-full-disk-encryption) and install it in your Arch Linux Live environment.

```shell
pacman -Sy git make yubikey-personalization
cd yubikey-full-disk-encryption
make install
```

## Configure ykfde

Open `/etc/ykfde.conf` and set `YKFDE_CHALLENGE_SLOT=2` because we want to use the second slot.
Set `YKFDE_CHALLENGE_PASSWORD_NEEDED=1` so it asks for the password (2FA). Leave other settings as is. It will be changed later.

!!! note
    Please compare it carefully with the latest version you have downloaded.

It should look something like this

```ini
### Configuration for 'yubikey-full-disk-encryption'.
### Remove hash (#) symbol and set non-empty ("") value for chosen options to
### enable them.

### *REQUIRED* ###

# Set to non-empty value to use 'Automatic mode with stored challenge (1FA)'.
#YKFDE_CHALLENGE=""

# Use 'Manual mode with secret challenge (2FA)'.
YKFDE_CHALLENGE_PASSWORD_NEEDED="1"

# YubiKey slot configured for 'HMAC-SHA1 Challenge-Response' mode.
# Possible values are "1" or "2". Defaults to "2".
YKFDE_CHALLENGE_SLOT="2"

### OPTIONAL ###

# UUID of device to unlock with 'cryptsetup'.
# Leave empty to use 'cryptdevice' boot parameter.
#YKFDE_DISK_UUID=""

# LUKS encrypted volume name after unlocking.
# Leave empty to use 'cryptdevice' boot parameter.
#YKFDE_LUKS_NAME=""

# Device to unlock with 'cryptsetup'. If left empty and 'YKFDE_DISK_UUID'
# is enabled this will be set as "/dev/disk/by-uuid/$YKFDE_DISK_UUID".
# Leave empty to use 'cryptdevice' boot parameter.
#YKFDE_LUKS_DEV=""

# Optional flags passed to 'cryptsetup'. Example: "--allow-discards" for TRIM
# support. Leave empty to use 'cryptdevice' boot parameter.
#YKFDE_LUKS_OPTIONS=""

# Number of times to try assemble 'ykfde passphrase' and run 'cryptsetup'.
# Defaults to "5".
#YKFDE_CRYPTSETUP_TRIALS="5"

# Number of seconds to wait for inserting YubiKey, "-1" means 'unlimited'.
# Defaults to "30".
#YKFDE_CHALLENGE_YUBIKEY_INSERT_TIMEOUT="30"

# Number of seconds to wait after successful decryption.
# Defaults to empty, meaning NO wait.
#YKFDE_SLEEP_AFTER_SUCCESSFUL_CRYPTSETUP=""

# Verbose output. It will print all secrets to terminal.
# Use only for debugging.
#DBG="1"
```

## Encrypt the LVM partition

Next, we format the LVM partition.

The command `ykfde-format` will prompt to enter your challenge (2FA) password. Use a strong password which you can remember. You have to type this password every time to get access via YubiKey and to decrypt your disk. The command `ykfde-open` will unlock a LUKS encrypted volume on a running system.

```shell
ykfde-format --cipher aes-xts-plain64 --key-size 512 --hash sha256 --iter-time 5000 --type luks2 /dev/[device LVM partition]
ykfde-open -d /dev/[device LVM partition] -n cryptlvm
```

Display the crypt volume with `ls -la /dev/mapper/`. Next step is to prepare the logical volumes.

## Prepare LVM volumes

Follow the instructions at the Arch Wiki page [Preparing the logical volumes](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Preparing_the_logical_volumes).

Summarized, execute the following commands.

```shell
pvcreate /dev/mapper/cryptlvm
vgcreate ArchVolGroup /dev/mapper/cryptlvm

lvcreate -L 17G ArchVolGroup -n swap
lvcreate -l 100%FREE ArchVolGroup -n root

mkfs.ext4 /dev/ArchVolGroup/root
mkswap /dev/ArchVolGroup/swap

mount /dev/ArchVolGroup/root /mnt
swapon /dev/ArchVolGroup/swap
```

## Prepare the efi partition

You have already prepared a small partition on the disk. First, format the partition as FAT32.

```shell
mkfs.fat -F32 /dev/[efi partition]
```

## Encrypted boot partition

The last volume is `/boot` which should also be encrypted. You can not use a YubiKey here, but it is protected with a password.
The Arch Wiki page [Preparing the boot partition](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Preparing_the_boot_partition_5 "Preparing the boot partition")
describes this in more detail. The `efi` partition will be mounted to `/boot/efi`.

Execute the following commands and replace `[boot partition]` with the boot partition of your device e.g. `nvme0n1p2`
and replace `[efi partition]` with the efi partition of your device e.g. `nvme0n1p1`.

The command `cryptsetup luksFormat` will prompt to enter your password to decrypt the boot partition at boot.
Use a strong password which you can remember.

```shell
cryptsetup luksFormat --type luks1 /dev/[device 3rd partition]
cryptsetup open /dev/[device 3rd partition] cryptboot

mkfs.ext4 /dev/mapper/cryptboot

mkdir /mnt/boot
mount /dev/mapper/cryptboot /mnt/boot

mkdir /mnt/boot/efi
mount /dev/[device 2nd partition] /mnt/boot/efi
```

## Keyfile for initramfs

[With a keyfile embedded in the initramfs](https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#With_a_keyfile_embedded_in_the_initramfs "With a keyfile embedded in the initramfs")
you don't have to unlock the `/boot` partition twice. The `/boot` partition will be mounted if the system starts, so updates can be performed.

Create a randomized generated key file with the following lines and add this keyfile to the boot LUKS partition (replace `[boot partition]` with the boot partition of your device e.g. `nvme0n1p2`).
The keyfile is copied in the root folder of the new Arch linux environment.

```shell
dd bs=512 count=4 if=/dev/urandom of=/mnt/crypto_keyfile.bin
chmod 000 /mnt/crypto_keyfile.bin
cryptsetup luksAddKey /dev/[boot partition] /mnt/crypto_keyfile.bin
```
