#!/bin/bash

if [ "$1" == "toggle" ];then
    if [ "$2" == "sources" ];then
        for SOURCE in `pacmd list-sources | grep 'index:' | cut -b12-`
	do
	    pactl set-source-mute $SOURCE toggle
	done
    else
        for SINK in `pacmd list-sinks | grep 'index:' | cut -b12-`
        do
            pactl set-sink-mute $SINK toggle
        done
    fi
else
    for SINK in `pacmd list-sinks | grep 'index:' | cut -b12-`
    do
    	pactl set-sink-volume $SINK $1
    done
fi

