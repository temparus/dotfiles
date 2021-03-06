# ZSH Alias

mountusb() { mkdir -p /mnt/usb; sudo mount -o gid=user,fmask=113,dmask=002 "$1" /mnt/usb; }

alias umountusb='sudo umount /mnt/usb'
alias please='sudo'
alias weather='curl wttr.in'

# Clear stored YubiKey serial numbers and scan for devices.
alias cyk='gpg-connect-agent "scd serialno" "learn --force" /bye'
