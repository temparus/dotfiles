# Setup

The only thing how to make a Windows machine a usable workstation, is to have a Linux at hand (at least for development). This is very easy with WSL 2 and it is very well integrated into Windows.

## Preparations

Enable WSL 2 on the Windows 10 operation system by following the [guide from Microsoft](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

Install the desired Linux distribution from the Microsoft Store.

Open the installed Linux distribution (opens a terminal) and clone this repository to the system.

## Install zsh, thefuck and git

Create the following symlinks:

```shell
ln -s <path-to-repository>/gitconfig ~/.gitconfig
ln -s <path-to-repository>/zshrc ~/.zshrc
ln -s <path-to-repository>/zsh ~/.zsh
ln -s <path-to-repository>/zshrc ~/.zshrc
```

Install git, zsh and oh-my-zsh

```shell
sudo apt install git zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
```

Install thefuck

```shell
sudo apt install python3-dev python3-pip python3-setuptools
sudo pip3 install thefuck
```

Initialize the new shell by running `zsh`.

Change the default shell to zsh so that it is used instead of bash when opening a new terminal.

```shell
chsh -s $(which zsh)
```

## Install Docker

Install Docker Desktop on Windows by following the [guide from Docker](https://docs.docker.com/docker-for-windows/install/).

The Docker Desktop application should automatically detect the WSL 2 installation and ask whether this should be used for running docker containers. Click yes.

This allows to use docker directly in Linux or from the Windows command line. All containers will be started in Linux though. The running containers can be inspected using the Docker Desktop application GUI.

## Install Visual Studio Code

Install Visual Studio Code on Windows and enable the extension `Remote - WSL` from Microsoft.

You can open a folder on the Linux filesystem with Visual Studio Code by typing `code .` into the Linux console. This will automatically start VSCode in Windows and mount the remote location using `Remote - WSL`. Every console you open within VSCode will automatically be a Linux shell.
