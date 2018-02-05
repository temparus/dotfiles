#!/bin/sh

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

#exec ck-launch-session dbus-launch cinnamon-session
exec bspwm
