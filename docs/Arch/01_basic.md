# Setup

This is a general system setup guide for Arch. I recommend to use the distro Manjaro for easy installation.

## Install Basic Applications

Yay is used to install AUR packages.

```shell
sudo pacman -S yay git code
```

I use the following community packages. 

```shell
sudo yay -S spotify visual-studio-code-bin
```

## Clone dotfiles repository

Clone the dotfiles repository into the home directory.

## Install zsh, thefuck

Install git, zsh, oh-my-zsh, zplug and thefuck

```shell
sudo yay -S git zsh thefuck
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
```

Add the configuration files by executing the following command in the root directory of this repository.

```shell
stow zsh
```

Initialize the new shell by running `zsh`.

Change the default shell to zsh so that it is used instead of bash when opening a new terminal.

```shell
chsh -s $(which zsh)
```

## Install window manager bspwm

If you want to use bspwm as a window manager with KDE instead of KWin, follow the instructions below.

Install all required packages first.

```shell
sudo yay -S bspwm polybar sxhkd wmctrl
```

Apply the prepared configuration files.

```shell
stow polybar sxhkd bspwm
```

Enable bspwm as window manager

```shell
stow bspwm-kde
```

Restart the computer to use bspwm as window manager.
