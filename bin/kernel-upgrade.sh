#!/bin/bash

USER="slu"
AUTHOR="Sandro Lutz <code@temparus.ch>"
CURRENT_KV=$(uname -r)
DEVICE_NAME=$(uname -n)
NEW_KV=$(basename `realpath /usr/src/linux`)

# This assumes that the kernel ebuild was emerged with the
# 'symlink' use flag set, so that /usr/src/linux points to the
# newly emerged kernel.
cp "/usr/src/linux-${CURRENT_KV}/.config" "/usr/src/linux/"

cd "/usr/src/linux"
make olddefconfig

# Make a copy for the dotfiles repository
cp "/usr/src/linux/.config" "/home/${USER}/.config/kernel/${DEVICE_NAME}.config"
chown "${USER}" "/home/${USER}/.config/kernel/${DEVICE_NAME}.config"
chgrp "${USER}" "/home/${USER}/.config/kernel/${DEVICE_NAME}.config"

cd "/home/${USER}"

#git add -f ".config/kernel/${DEVICE_NAME}.config"
#git commit --author "${AUTHOR}" -m "[${DEVICE_NAME}] Update kernel config to ${NEW_KV}"
# git push

cd /usr/src/linux

make -j5 && make modules_install
mount /boot
make install
grub-mkconfig -o /boot/grub/grub.cfg

