#!/bin/sh

isHDMI1Connected() {
    local xRandr=$(xrandr -q)
    [ "$xRandr" == "${xRandr#*HDMI-1 con}" ] || return 0
    return 1
}

isDP2Connected() {
    local xRandr=$(xrandr -q)
    [ "$xRandr" == "${xRandr#*DP-2 con}" ] || return 0
    return 1
}

if isHDMI1Connected
then
# Command for second screen
    xrandr --output eDP-1 --auto --output HDMI-1 --auto --right-of eDP-1
# Command for screen mirroriing
    #xrandr --fb 2560x1440 --output eDP-1 --mode 2560x1440 --output HDMI-1 --mode 1920x1080 --scale-from 2560x1440 --same-as eDP-1
    #xrandr --fb 1920x1080 --output eDP-1 --mode 1920x1080 --output HDMI-1 --mode 1920x1080 --scale-from 1920x1080 --same-as eDP-1
elif isDP2Connected
then
    xrandr --output eDP-1 --auto --output DP-2 --auto --above eDP-1
else
    xrandr --output eDP-1 --auto --output HDMI-1 --off --output DP-2 --off
fi

