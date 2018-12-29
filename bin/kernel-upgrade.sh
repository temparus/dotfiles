#!/bin/bash

USER="slu"
AUTHOR="Sandro Lutz <code@temparus.ch>"
CURRENT_KV=$(uname -r)
DEVICE_NAME=$(uname -n)
NEW_KV=$(basename `realpath /usr/src/linux`)

if [[ $CURRENT_KV = $NEW_KV ]]; then
  echo "Already on Latest Version"
  read -r -p "Run menuconfig? [Y/n] " response
  response=${response,,} # tolower
  if ! [[ $response =~ ^(no|n)$ ]]; then
    ( cd $path && make menuconfig )
  fi
else
  echo "Performing Upgrade $CURRENT_KV -> $NEW_KV"

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

  alias dots="git --git-dir=/home/${USER}/.dots.git/ --work-tree=/home/${USER}/"
  dots add -f ".config/kernel/${DEVICE_NAME}.config"
  dots commit --author "${AUTHOR}" -m "[${DEVICE_NAME}] Update kernel config to ${NEW_KV}"
  dots push
fi

echo "Building kernel $NEW_KV"

cd /usr/src/linux

make -j5 && make modules_install
mount /boot

echo "Installing kernel $NEW_KV"

make install
# only keep the newest three kernels
eclean-kernel -n 3
grub-mkconfig -o /boot/grub/grub.cfg

