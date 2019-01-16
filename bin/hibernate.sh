#!/bin/sh

script_dir=$(dirname $0)

function disable_acpi_wakeup {
  ACTIVE=$(grep enabled /proc/acpi/wakeup | cut -f 1 | grep "$1")
  if [ -n "$ACTIVE" ]; then 
    sudo su -c "echo \"$ACTIVE\" > /proc/acpi/wakeup"
  fi
}

disable_acpi_wakeup XHC

$script_dir/lock.sh && sudo s2ram

