#!/bin/bash
# Script to upgrade all installed packages of Gentoo

# Sync package database
emerge --sync

# Update any overlays
layman -S

# Upgrade every additional package installed on the system
emerge -avuDN --with-bdeps y --keep-going world

# Update configuration files
etc-update

# Removes unused dependencies
emerge -av --depclean

# Fix broken stuff
revdep-rebuild

# Remove old source files
eclean -d distfiles

