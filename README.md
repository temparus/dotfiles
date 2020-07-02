# dotfiles

This repository contains the personal configuration files for various linux applications on my devices.

More information about how to access the documentation can be found in [docs/README.md](docs/README.md).

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

## Additional Documentation

See [additional install instructions](.docs/README.md)

## NOTES

Polybar installed dependencies:

* siji-git
* wireless_tools
* termsyn-font
* papirus-icon-theme
