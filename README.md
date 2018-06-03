# Gentoo

(This guide is thought only to be an additional help to the official Gentoo Handbook!)

## System update/upgrade

```bash
system-update  # update all installed packages
kernel-upgrade # upgrade kernel to newer version (if new gentoo-sources have been installed with the above command)
```

## Build the Kernel manually

The Kernel configuration can be found in ```.config/kernel/.config```. Copy this file to ```/usr/src/linux```

To configure the kernel correctly, boot into an Ubuntu LIVE system and check what kernel drivers are loaded with ```lspci -k```.

1. Go to the directory ```/usr/src/linux```
2. Adjust the configuration with ```make menuconfig```
3. Build the kernel with ```make && make modules_install```.
4. Mount the boot partition and install the new kernel with ```make install```
5. Update Grub boot list with ```grub-mkconfig -o /boot/grub/grub.cfg```

## Lenovo ThinkPad X1 Yoga: Initial System Configuration

More information on the [Gentoo Wiki](https://wiki.gentoo.org/wiki/Lenovo_ThinkPad_X1_Yoga_2nd_Generation).

### Configure Portage

Add/change the following lines to the file ```/etc/portage/make.conf```:

```bash
USE="alsa"
INPUT_DEVICES="libinput wacom"
VIDEO_CARDS="intel i965"
MAKEOPTS="-j5"
GRUB_PLATFORMS="efi-64"
(CPU_FLAGS_X86="aes avx avx2 fma3 mmx mmxext pclmul popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3")
```

Generate the correct CPU_FLAGS_X86 content with ```cpuid2cpuflags```.

### Install Required Packages

```bash
emerge --ask sys-kernel/linux-firmware # binary blobs for some hardware
emerge -va dev-libs/libinput           # Wacom Touchscreen / Pen input
```

### Configure X

Create the file ```/etc/X11/xorg.conf.d/90-libinput.conf```:

```bash
Section "InputClass"
  Identifier "libinput touchpad catchall"
  MatchIsTouchpad "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
  Option "Tapping" "on"
  Option "ClickMethod" "clickfinger"
EndSection
```

Create the file ```/etc/X11/xorg.conf.d/50-wacom.conf```:

```bash
Section "InputClass"
  Identifier "Wacom class"
  MatchProduct "Wacom|WACOM|Hanwang|PTK-540WL|ISDv4|ISD-V4|ISDV4"
  MatchDevicePath "/dev/input/event*"
  Driver "wacom"
  Option "Gesture" "off"
EndSection
```
