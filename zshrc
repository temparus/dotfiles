# ZSH Configurations

source $HOME/.zsh/completion.zsh
source $HOME/.zsh/key-bindings.zsh
source $HOME/.zsh/directories.zsh
source $HOME/.zsh/history.zsh
source $HOME/.zsh/spectrum.zsh
source $HOME/.zsh/termsupport.zsh
source $HOME/.zsh/alias.zsh
source $HOME/.zsh/grep.zsh
source $HOME/.zsh/transfer-sh.zsh
source $HOME/.zsh/misc.zsh


# Plugins

source $HOME/.zplug/init.zsh

zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "arzzen/calc.plugin.zsh"
zplug "viko16/gitcd.plugin.zsh"

zplug "plugins/git",            from:oh-my-zsh
#zplug "plugins/npm",            from:oh-my-zsh
zplug "plugins/thefuck",        from:oh-my-zsh
zplug "plugins/common-aliases", from:oh-my-zsh
zplug "themes/candy",           from:oh-my-zsh, as:theme


# Install plugins if there are plugins that have not been installed
if ! zplug check; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load 

export EDITOR='vim'
export PATH="$HOME/go/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then exec startx; fi

