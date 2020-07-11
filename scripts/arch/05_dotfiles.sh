#!/bin/bash

############################################
##   Installation script for Arch Linux   ##
## -------------------------------------- ##
## Chapter: Install dotfiles              ##
##          (run as you personal user!)   ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

# Relative path from the working directory to the script location.
DIR=$(dirname "${BASH_SOURCE[0]}")

source "${DIR}/../helpers.sh"

# Functions
install_stow() {
    sudo pacman --noconfirm -Sy stow
}

configure_git() {
    yay -S git
}

install_zsh() {
    yay -S zsh zsh-completions thefuck ttf-hack
    # install zplug
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    rm ../.zshrc
    stow zsh
    stow X
}

install_x_server() {
    # TODO: Some packages are missing to successfully start bspwm.
    #       Need to find out which packages are missing here!
    sudo pacman --noconfirm -S xorg-server xorg-xinit xf86-input-libinput xf86-video-intel mesa
}

install_bspwm_polybar_sxhkd_urxvt() {
    sudo pacman --noconfirm -S bspwm sxhkd picom rofi rxvt-unicode xsecurelock xss-lock \
                               ttf-font-awesome noto-fonts
    yay -S polybar feh
    stow picom bspwm sxhkd polybar
}

install_yubico_pam() {
    sudo pacman --noconfirm -S yubico-pam
    # TODO: finish setup instructions!
}

echo "=================================="
echo -e "Step 05: Install dotfiles\n"

current_dir=$(pwd)
cd "${DIR}/../../"

task "Installing package: stow" install_stow
task "Configuring git" configure_git
install_zsh()
task "Installing X server" install_x_server
install_bspwm_polybar_sxhkd()

cd $current_dir
