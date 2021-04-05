# Setup

The only thing how to make a Windows machine a usable workstation, is to have a Linux at hand (at least for development). This is very easy with WSL 2 and it is very well integrated into Windows.

!!! info "Package install instructions"
    All package install instructions are for Ubuntu. If you are using another WSL 2 distribution, adapt those commands accordingly. 


## Preparations

1. Enable WSL 2 on the Windows 10 operating system by following the [guide from Microsoft](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
2. Install the desired Linux distribution from the Microsoft Store.
3. Open the installed Linux distribution (opens a terminal) and clone this repository to the system.


## Install stow

We use `stow` to easily install all configuration files.

```shell
sudo apt install stow
```


## Install zsh, thefuck and git

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

First, we have to remove the default `.zshrc` file. Otherwise, our own configuration files cannot be installed.

```shell
rm ~/.zshrc
```

Install the configuration files.

```shell
stow git zsh
```

Initialize the new shell by running `zsh`.

Change the default shell to zsh so that it is used instead of bash when opening a new terminal.

```shell
chsh -s $(which zsh)
```


## Configure YubiKey SmartCard

The YubiKey can be configured to store three different PGP keys to encrypt, sign and authenticate. The keys cannot be read. By default, you cannot use any device within WSL2, so the YubiKey wont work out of the box.

!!! note
    This guide is based on the blog article [Yubikey, gpg, ssh and WSL2](https://blog.nimamoh.net/yubi-key-gpg-wsl2/) written by Nimamoh.

!!! note
    This guide does not cover how to configure your YubiKey with PGP Keys.

First, follow the instructions on how to 
[Configure YubiKey SmartCard for Windows](../../01_basics/#yubikey-smartcard).

Now we want to make the YubiKey available in the WSL2 environment:

!!! note "Assumptions"
    We assume that you also have installed the configuration package `zsh`. If you do not, you should place the following lines in your `.bashrc` or similar file.

    ```bash
    $HOME/.local/bin/gpg-agent-relay start
    export SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh
    ```

1. We will use [npiperelay](https://github.com/NZSmartie/npiperelay) so that we can use gpg4win gpg-agent from the WSL2 environment. This allows linux applications to access named pipes from Windows.<br/>
   Place the file [npiperelay.exe](files/npiperelay.exe) in `%appdata%\npiperelay\npiperelay.exe`.
2. We use [wsl-ssh-pageant](https://github.com/benpye/wsl-ssh-pageant) so that we can a pageant style SSH agent from within our WSL 2 environment.<br/>
   Place the file [wsl-ssh-pageant-amd64-gui.exe](files/wsl-ssh-pageant-amd64-gui.exe) in `%appdata%\wsl-ssh-pageant\wsl-ssh-pageant-amd64-gui.exe`
3. Open a terminal for your WSL2 environment. Make sure that you have cloned this repository and installed `stow` (See [#install-stow](#install-stow)).<br/><br/>
   Install the required configuration files and scripts:
   ```shell
   stow wsl2-gpg
   ```
4. Install `socat` in your WSL instance:
   ```shell
   sudo apt install socat
   ```
5. Restart your computer, open a terminal for your WSL2 environment and run `ssh-add -L`.<br/>
   If you see a key with the identifier starting with `cardno:`, the YubiKey Authentication Key is ready to be used for SSH connections within your WSL2 environment.

!!! warning
    Do not forget to import your public key if you want to sign your git commits!

!!! tip
    If the gpg-agent-relay cannot be started, you may have to start Kleopatra in Windows first.

!!! tip
    If you are using multiple YubiKeys with the same keys, you must rescan for the correct serial number, before you can use the other device. Otherwise, the gpg agent will prompt you to connect the device with the correct serial number.<br/><br/>
    Use the following command or the alias `cyk` to reset the stored serial number:

    ```shell
    gpg-connect-agent "scd serialno" "learn --force" /bye
    ```

### Troubleshooting

Check if the realy is running (in your WSL2 shell)
```shell
~/.local/bin/gpg-agent-relay status
```

Check for errors by launching the script in the foreground.

```shell
~/.local/bin/gpg-agent-relay foreground
```


## Install Docker

Install Docker Desktop on Windows by following the [guide from Docker](https://docs.docker.com/docker-for-windows/install/).

The Docker Desktop application should automatically detect the WSL 2 installation and ask whether this should be used for running docker containers. Click yes.

This allows to use docker directly in Linux or from the Windows command line. All containers will be started in Linux though. The running containers can be inspected using the Docker Desktop application GUI.


## Install Visual Studio Code

Install Visual Studio Code on Windows and enable the extension `Remote - WSL` from Microsoft.

You can open a folder on the Linux filesystem with Visual Studio Code by typing `code .` into the Linux console. This will automatically start VSCode in Windows and mount the remote location using `Remote - WSL`. Every console you open within VSCode will automatically be a Linux shell.
