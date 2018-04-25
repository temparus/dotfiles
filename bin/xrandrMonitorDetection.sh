#!/bin/sh

isHDMI1Connected() {
    local xRandr=$(xrandr -q)
    [ "$xRandr" == "${xRandr#*HDMI1 con}" ] || return 0
    return 1
}

if isHDMI1Connected
then
	xrandr --output eDP1 --auto --output HDMI1 --auto --right-of eDP1
else
 	xrandr --output eDP1 --auto --output HDMI1 --off
fi

