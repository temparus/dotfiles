# Use GPG (with YubiKey smartcard) for SSH
if [ -L "$HOME/.local/bin/gpg-agent-relay" ]; then
    # Configuration for WSL2
    $HOME/.local/bin/gpg-agent-relay status > /dev/null
    if [ "$?" -ne 0 ]; then
        $HOME/.local/bin/gpg-agent-relay start
    fi
    export SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh
else
    # Configuration for bare metal linux
    export GPG_TTY="$(tty)"
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    gpgconf --launch gpg-agent
    gpg-connect-agent updatestartuptty /bye 1>/dev/null
fi
