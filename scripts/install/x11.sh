#!/bin/bash

############################################
##      Installation script for X11       ##
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

add_keyword "media-fonts/fontawesome ~amd64"
add_keyword "x11-misc/sxhkd ~amd64"
add_keyword "x11-wm/bspwm ~amd64"

add_use_flags x11-misc polybar "network"

emerge -v --autounmask-continue y
        media-fonts/hack \
        media-fonts/fontawesome \
        media-fonts/noto \
        media-fonts/roboto \
        media-fonts/unifont \
        x11-apps/xrandr \
        x11-apps/xsetroot \
        x11-base/xorg-server \
        x11-libs/xcb-util-cursor \
        x11-misc/compton \
        x11-misc/i3lock \
        x11-misc/polybar \
        x11-misc/redshift \
        x11-misc/rofi \
        x11-misc/sxhkd \
        media-sound/pavucontrol \
        x11-terms/rxvt-unicode \
        x11-wm/bspwm

read -p "Do you want to install the additional UI packages? [yN]: " answer
case ${answer:0:1} in
    y|Y )
        # Used for visual-studio-code
        layman -a jorgicio

        add_keyword "net-im/telegram-desktop-bin ~amd64"
        add_keyword "www-client/vivaldi ~amd64"
        add_keyword "app-editors/visual-studio-code ~amd64"
        add_keyword "media-sound/spotify ~amd64"

        add_use_flags media-video vlc "lua matroska vnc"

        emerge -v --autounmask-continue \
                net-im/telegram-desktop-bin \
                www-client/vivaldi \
                app-editors/visual-studio-code \
                app-text/evince \
                media-sound/spotify \
                media-video/vlc
    ;;
    * )
    ;;
esac

read -p "Do you want to install LibreOffice now? [yN]: " answer
case ${answer:0:1} in
    y|Y )
        emerge -v --autounmask-continue app-office/libreoffice
    ;;
    * )
    ;;
esac
