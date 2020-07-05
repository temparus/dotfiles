# Install Arch Linux

This chapter describes how to install a minimal Arch Linux.

!!! note "Installation Guide on Arch Wiki"
    You also find an [up-to-date installation guide](https://wiki.archlinux.org/index.php/installation_guide) at the Arch Wiki.

## Install essential packages

Install the base system.

```shell
pacstrap /mnt base linux linux-firmware base-devel lvm2 yubikey-manager pcsc-tools make cryptsetup
```

I also install the following packages:

```shell
pacstrap /mnt vim git man-db man-pages iproute2 networkmanager exfat-utils ntfs-3g
```

## Generate fstab

The following command will generate the fstab entries of the currently mounted partitions.

```shell
genfstab -U -p /mnt >> /mnt/etc/fstab
```

Check it out with `cat /mnt/etc/fstab` and verify it.

## Copy YubiKey Full Disk Encryption

Next step is to copy the [yubikey-full-disk-encryption](https://github.com/agherzan/yubikey-full-disk-encryption) folder
to the `/mnt` folder because it will be installed later. The YubiKey challenge is stored in a file to make it
available inside the new system. More on that later. Replace `[Your YubiKey password]` with your YubiKey password.

```shell
cp -r yubikey-full-disk-encryption /mnt/home/
echo "export YKFDE_CHALLENGE=$(printf '[Your YubiKey password]' | sha256sum | awk '{print $1}')" > /mnt/home/challenge.txt
```

Copy `/etc/ykfde.conf` to `/mnt/home` so you can use this file later in your new environment.

## chroot

It's time to switch into your new system with `arch-chroot /mnt` and prepare some stuff. After successfully changed root to the new system, execute the following lines to make the hosts *lvm* available here for `grub-mkconfig`.

You will need the same packages like in chapter *01: Getting Started*.

```shell
pacman -Sy yubikey-manager yubikey-personalization pcsc-tools libu2f-host make json-c cryptsetup
```

```shell
mkdir /run/lvm
mount --bind /hostrun/lvm /run/lvm
```

Next step is to install the *yubikey-full-disk-encryption* helper scripts. If they are not already copied in your home
folder, you can it download from the GitHub repository [yubikey-full-disk-encryption](https://github.com/agherzan/yubikey-full-disk-encryption).

```shell
cd /home/yubikey-full-disk-encryption
make install
```

Copy `/home/ykfde.conf` to  `/etc/ykfde.conf` so you have your previous settings or configure the file as described in chapter *Prepare YubiKey*. The YubiKey challenge will now be stored in the `ykfde.conf` file. The environment variable with the YubiKey challenge is loaded into the environment so it can be set into the `ykfde.conf` file with the command `sed`.

```shell
source /home/challenge.txt
sed -i "s/#YKFDE_CHALLENGE=\"/YKFDE_CHALLENGE=\"$YKFDE_CHALLENGE/g" /etc/ykfde.conf
```

Check that the YubiKey challenge was successfully saved to `/etc/ykfde.conf` with `cat /etc/ykfde.conf`.

## Time Zone

Set the time zone and generate `/etc/adjtime`:

```shell
ls -sf /usr/share/zoneinfo/<Region>/<City> /etc/localtime
hwclock --systohc
```

## Localization

Edit `/etc/locale.gen` and uncomment `end_US.UTF-8 UTF-8` and other locales needed. Generate the locales b y running:

```shell
locale-gen
```

Set the `LANG` variable in the file `/etc/locale.conf` as

```shell
LANG=en_US.UTF-8
```

## Network Configuration

Create the hostname file `/etc/hostname` with the device hostname as content.

Add matching entries to `/etc/hosts`.

```ini
127.0.0.1      localhost
::1            localhost
127.0.1.1      <myhostname>.localdomain <myhostname>
```

## mkinitcpio

The next step is to prepare the `mkinitcpio.conf` to detect and unlock an encrypted partition at boot. Open the file with
`vim /etc/mkinitcpio.conf` and replace the *HOOKS* line with the following content.

!!! warning
    Don't add `encrypt` hook, because we ues ykfde and respect the order!

```ini
HOOKS=(base udev autodetect modconf block keymap lvm2 filesystems fsck keyboard ykfde)
```

Additionally the *ext4* module is needed. Add *ext4* to the *MODULES*. It should look like this line:

```ini
MODULES=(ext4)
```

Recreate the initramfs:

```shell
mkinitcpio -P
```

## GRUB

First, install grub with `pacman -Sy grub`.

Then, get a list of your device IDs with `lsblk -f`. Alternative `blkid` can be used.

You will need the UUID from the *lvm partition* and the
UUID of *ArchVolGroup-root* . Open the GRUB config file with `vim /etc/default/grub` and add these two lines with your UUIDs.

```ini
GRUB_CMDLINE_LINUX="cryptdevice=UUID=[lvm partition UUID]:cryptlvm root=UUID=[ArchVolGroup-root UUID]"
GRUB_ENABLE_CRYPTODISK=y
```

Generate the grub config file. You may install the package `efibootmgr` first.

```shell
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```

## Create a User

Add a new user and set a password.

```shell
useradd -m <username>
passwd <username>
```

Promote the user to an administrator so sudo can be used.

```shell
groupadd sudo
usermod -a -G sudo <username>
```

Update `/etc/sudoers` file so that all members of the group `sudo` can run all commands with sudo.

```ini
%sudo   ALL=(ALL) ALL
```

## Configure ykfde.conf

Open the file with `vim /etc/ykfde.conf` and enable/set `YKFDE_LUKS_NAME="cryptlvm"` and  `YKFDE_DISK_UUID=[lvm partition UUID]`
(replace `[lvm partition UUID]` with the UUID of the lvm partition).

It should look something like this

```ini
### Configuration for 'yubikey-full-disk-encryption'.
### Remove hash (#) symbol and set non-empty ("") value for chosen options to
### enable them.

### *REQUIRED* ###

# Set to non-empty value to use 'Automatic mode with stored challenge (1FA)'.
YKFDE_CHALLENGE="8fa0acf6233b42e2d28a31a315cd213748d48f28eaa63d7590509392316b3016"

# Use 'Manual mode with secret challenge (2FA)'.
YKFDE_CHALLENGE_PASSWORD_NEEDED="1"

# YubiKey slot configured for 'HMAC-SHA1 Challenge-Response' mode.
# Possible values are "1" or "2". Defaults to "2".
YKFDE_CHALLENGE_SLOT="2"

### OPTIONAL ###

# UUID of device to unlock with 'cryptsetup'.
# Leave empty to use 'cryptdevice' boot parameter.
YKFDE_DISK_UUID="<lvm partition UUID>"

# LUKS encrypted volume name after unlocking.
# Leave empty to use 'cryptdevice' boot parameter.
YKFDE_LUKS_NAME="cryptlvm"

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

## Install yay

Install Yet Another Yogurt to easily install AUR packages.

```shell
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```
