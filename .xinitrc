#!/bin/sh

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

export _JAVA_AWT_WM_NONREPARENTING=1

exec bspwm
