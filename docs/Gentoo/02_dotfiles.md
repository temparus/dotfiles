# Dotfiles

Clone the dotfiles repository to the system.

## System Configuration

Create the following directories:

```shell
mkdir /usr/local/bin /root/.local/bin /var/lib/iptables
```

Copy the following files:

```shell
sudo cp portage/make-cryptopad.conf /etc/portage/make.conf
sudo cp scripts/vpn/vpn.openrc /etc/init.d/vpn
sudo cp scripts/vpn/network-changed.sh /root/.local/bin/network-changed.sh
sudo cp scripts/vpn/iptables-config.sh /usr/local/bin/iptables-config
sudo cp config/iptables/default.ipv4.rules /var/lib/iptables/default.ipv4.rules
sudo cp config/iptables/default.ipv6.rules /var/lib/iptables/default.ipv6.rules
sudo cp config/iptables/vpn-kill.ipv4.rules /var/lib/iptables/vpn-kill.ipv4.rules
sudo cp config/iptables/vpn-kill.ipv6.rules /var/lib/iptables/vpn-kill.ipv6.rules
sudo cp scripts/kernel-upgrade.sh /usr/local/bin/kernel-upgrade
sudo cp scripts/system-update.sh /usr/local/bin/system-update
```

## User Configuration

Create the following directories:

```shell
mkdir ~/.config ~/.config/sxhkd ~/.local/bin
```

Create the following symlinks:

```shell
ln -s <path-to-repository>/gitconfig ~/.gitconfig
ln -s <path-to-repository>/zshrc ~/.zshrc
ln -s <path-to-repository>/zsh ~/.zsh
ln -s <path-to-repository>/zshrc ~/.zshrc
ln -s <path-to-repository>/xinitrc ~/.xinitrc
ln -s <path-to-repository>/Xresources ~/.Xresources
ln -s <path-to-repository>/config/polybar ~/.config/polybar
ln -s <path-to-repository>/config/sxhkd/sxhkdrc ~/.config/sxhkd/sxhkdrc
ln -s <path-to-repository>/config/compton.conf ~/.config/compton.conf
ln -s <path-to-repository>/config/redshift.conf ~/.config/redshift.conf
ln -s <path-to-repository>/config/audio.sh ~/.local/bin/manipulate-audio
ln -s <path-to-repository>/config/hibernate.sh ~/.local/bin/hibernate
ln -s <path-to-repository>/config/lock.sh ~/.local/bin/lock
ln -s <path-to-repository>/config/xrandMonitorDetection.sh ~/.local/bin/detect-monitors
```
