# Lenovo ThinkPad X1 Yoga: Specific Configuration

More information on the [Gentoo Wiki](https://wiki.gentoo.org/wiki/Lenovo_ThinkPad_X1_Yoga_2nd_Generation).

## Configure Portage

Add/change the following lines to the file ```/etc/portage/make.conf```:

```bash
CFLAGS="-march=native -O2 -pipe"
CXXFLAGS="${CFLAGS}"
CHOST="x86_64-pc-linux-gnu"
USE="acl alsa pulseaudio ffmpeg glamor bluetooth zsh-completion imlib truetype gd \
     corefonts xft udisks http2"
INPUT_DEVICES="libinput evdev wacom"
VIDEO_CARDS="intel i915"
PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"
MAKEOPTS="-j5"
GRUB_PLATFORMS="efi-64"
LINGUAS="en"
(CPU_FLAGS_X86="aes avx avx2 fma3 mmx mmxext pclmul popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3")
```

Generate the correct CPU_FLAGS_X86 content with ```cpuid2cpuflags```.

### Install Required Packages

```bash
emerge --ask sys-kernel/linux-firmware # Binary blobs for some hardware
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
