#!/bin/bash

BLUETOOTH_DEVICE="hci0"

hciconfig $BLUETOOTH_DEVICE | grep "UP"

if [ $? -ne 0 ];then
    /etc/init.d/bluetooth start
    hciconfig $BLUETOOTH_DEVICE up
    bluetoothctl power on
    echo "bluetooth started"
else
    bluetoothctl power off
    hciconfig $BLUETOOTH_DEVICE down
    # bluetoothctl power off
    # /etc/init.d/bluetooth stop
    echo "bluetooth stopped!"
fi

