#!/bin/bash
# Script to upgrade all installed packages of Gentoo

# Sync package database
emerge --sync

# Update any overlays
layman -S

# Upgrade every additional package installed on the system
emerge -avuDN --with-bdeps y --keep-going world

# Apply updates to the configuration files and try again.
if [ $? -eq 1 ]; then
  etc-update --automode -5
  emerge -avuDN --with-bdeps y --keep-going world
fi

# Removes unused dependencies
emerge -av --depclean

# Fix broken stuff
revdep-rebuild

# Remove old source files
eclean -d distfiles

