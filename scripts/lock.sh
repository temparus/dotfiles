#!/bin/sh

if ! [[ $EUID -ne 0 ]]; then
  echo "Running this script as root is not intended! Please execute as a non-root user."
  exit 1
fi

i3lock -c 000000 -t -i /home/slu/pictures/lock.png
