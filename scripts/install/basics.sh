#!/bin/bash

############################################
##  Installation script for basic setup   ##
## -------------------------------------- ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

add_keyword () {
    if ! grep -q "$1" "/etc/portage/package.accept_keywords"; then
        echo "$1" >> /etc/portage/package.accept_keywords
    fi
}

add_use_flags () {
    if ! grep -q "$1/$2" "/etc/portage/package.use/$1"; then
        echo "$1/$2 $3" >> "/etc/portage/package.use/$1"
    fi
}

add_keyword "app-shells/thefuck ~amd64"
add_keyword "net-misc/openssh ~amd64"

add_use_flags app-portage layman "sync-plugin-portage git"

emerge -v --autounmask-continue \
        app-portage/layman \
        dev-vcs/git \
	dev-vcs/gti \
	app-misc/sl \
	app-admin/sudo \
        app-editors/vim \
        app-shells/thefuck \
        app-shells/zsh \
        app-shells/zsh-completion \
        app-shells/gentoo-zsh-completions \
        dev-python/scp \
        sys-process/htop \
        net-analyzer/iftop \
        net-dns/bind-tools \
        net-misc/dhcpcd \
        net-misc/openssh \
        sys-block/parted \
        sys-fs/dosfstools \
        sys-fs/ncdu \
        sys-kernel/gentoo-sources \
        sys-kernel/linux-firmware \
        sys-power/suspend

layman -S
