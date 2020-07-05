# Getting Started

This is a system setup guide for Arch. The resulting installation uses full-disk encryption for the root partition secured with YubiKey as 2nd factor, secure boot with signed kernels and YubiKey as 2nd factor for user login.

!!! note "Arch Installation Guide"
    This guide is not intended to be a self-contained guide for installing Arch Linux.
    Please take a look at the [Arch installation guide](https://wiki.archlinux.org/index.php/installation_guide) and work through this guide in parallel.

This guide is based on a [guide from Sandro Keil](https://github.com/sandrokeil/yubikey-full-disk-encryption-secure-boot-uefi).

First, boot into the bootable Arch Linux medium and connect to the network. For Wi-Fi, use `iwctl`. In the iwctl shell, use the following commands for example.

```shell
station wlan0 scan
station wlan0 get-networks
station wlan0 connect <ssid>
```

Update the system clock.

```shell
timedatectl set-ntp true
```
