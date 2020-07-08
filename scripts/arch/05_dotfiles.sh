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
    yay -S zsh zsh-completions thefuck
    # install zplug
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    rm ../.zshrc
    stow zsh
    stow X
}

install_x_server() {
    sudo pacman --noconfirm -S xorg-server xorg-xinit xf86-input-libinput xf86-video-intel mesa
}

install_bspwm_polybar_sxhkd_urxvt() {
    sudo pacman --noconfirm -S bspwm sxhkd picom rofi rxvt-unicode \
                               ttf-font-awesome noto-fonts ttf-hack
    yay -S polybar feh
    stow picom bspwm sxhkd polybar
}



echo "=================================="
echo -e "Step 05: Install dotfiles\n"

current_dir=$(pwd)
cd "${DIR}/../../"

install_stow()
configure_git()
install_zsh()
install_bspwm_polybar_sxhkd()

cd $current_dir
#task "Cleaning up temporary files" remove_arch_config_script
