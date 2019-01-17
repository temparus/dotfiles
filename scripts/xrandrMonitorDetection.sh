#!/bin/sh

isHDMI1Connected() {
    local xRandr=$(xrandr -q)
    [ "$xRandr" == "${xRandr#*HDMI-1 con}" ] || return 0
    return 1
}

if isHDMI1Connected
then
	xrandr --output eDP-1 --auto --output HDMI-1 --auto --right-of eDP-1
else
 	xrandr --output eDP-1 --auto --output HDMI-1 --off
fi

