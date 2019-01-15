#!/bin/bash

############################################
##  JetBrains Rider installation script   ##
## -------------------------------------- ##
## Author: Sandro Lutz <code@temparus.ch> ##
############################################

echo "Download the tar archive from the JetBrains Website and extract it to /opt/jetbrains/rider."

read -p "Done? [yN]: " answer
case ${answer:0:1} in
    y|Y )
        # Add symlink to rider executable
        ln -s /opt/jetbrains/rider/bin/rider.sh /usr/local/bin/rider
    ;;
    * )
    ;;
esac
