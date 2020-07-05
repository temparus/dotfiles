#!/bin/bash

#############################################
## Helper functions for other bash scripts ##
## --------------------------------------- ##
## Author: Sandro Lutz <code@temparus.ch>  ##
#############################################

LOGFILE="${PWD}/output.log"

# ----------------------------------
# Constants for text output styling
# ----------------------------------

BOLD="\033[1m"
UNDERLINE="\033[4m"

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color
NS="\033[0m" # No Style

# ----------------------------------
# Clear log file function
# ----------------------------------

clear_log() {
    > $LOGFILE
}

# ----------------------------------
# Select disk for further processing
#
# Also fills the variable "partitions"
# with all partitions of the selected
# drive.
# ----------------------------------
select_disk() {
    # Get all available disks
    disks=($(lsblk -l | sed -n 's/\([^ ]*\).* disk.*/\1/p'))

    for i in "${!disks[@]}"; do 
        printf "%s) %s\n" "$i" "${disks[$i]}"
        last_index=$i
    done

    while [ -z $disk ]; do
        read -p "Select disk [0-${last_index}]: " disk_index
        disk=${disks[$disk_index]}
    done
    partitions=($(lsblk -l | sed -n "s/\(${disk}[^ ]*\).* part.*/\1/p"))
}

# ----------------------------------
# Spinner function
# ----------------------------------

spinner() {
    local pid=$1
    local delay=0.10
    local spinstr='/-\|'
    printf "["
    while [ "$(ps a | awk '{print $1}' | grep "${pid}")" ]; do
        local temp=${spinstr#?}
        printf "%c]" "${spinstr}"
        local spinstr=${temp}${spinstr%"$temp"}
        sleep ${delay}
        printf "\b\b"
    done
    printf "\b   \b\b\b"
}

call_spinner() {
    echo -n "${2} "
    spinner ${1}
}

# ----------------------------------
# Task function
#
# Example: task "text to be shown in CLI" [command]
# ----------------------------------

task() {
    {
        echo "=========================================" >> $LOGFILE
        echo "Command: ${@:2}" >> $LOGFILE
        echo "-----------------------------------------" >> $LOGFILE
        (${@:2} >> $LOGFILE 2>&1)&
        call_spinner "${!}" "$1"
        wait %1
    }
    local retval=$?
    if [ $retval -ne 0 ]; then
        echo "-----------------------------------------" >> $LOGFILE
        echo "Command: ${@:2}" >> $LOGFILE
        echo "=========================================" >> $LOGFILE
        printf "${RED}error${NC} [code %d]\n" $retval
        printf "\nAn error occurred. See the log file for details.\n"
        printf "Logfile at ${UNDERLINE}${LOGFILE}${NS}\n"
        exit 1
    else
    	printf "${GREEN}success${NC}\n"
    fi
}

stop_on_error() {
    local retval=$?
    if [ $retval -ne 0 ]; then
        exit $retval
    fi
}

# ----------------------------------
# Confirm function
#
# Example: confirm "text to be shown in CLI" [optional exit code]
# ----------------------------------

confirm() {
    local exit_code="${2:-1}"
    read -p "$1 [y/N]: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit $exit_code
}


# ----------------------------------
# Select function
#
# Example: select_option 
# ----------------------------------

# select_option() {
#     PS3="Enter a number: "

#     select character in "$@"
#     do
#         # echo "Selected character: $character"
#         # echo "Selected number: $REPLY"
#         case $opt in
#             add)
#                 read -p "Enter the first number: " n1
#                 read -p "Enter the second number: " n2
#                 echo "$n1 + $n2 = $(($n1+$n2))"
#                 break
#                 ;;
#             subtract)
#                 read -p "Enter the first number: " n1
#                 read -p "Enter the second number: " n2
#                 echo "$n1 - $n2 = $(($n1-$n2))"
#                 break
#                 ;;
#             multiply)
#                 read -p "Enter the first number: " n1
#                 read -p "Enter the second number: " n2
#                 echo "$n1 * $n2 = $(($n1*$n2))"
#                 break
#                 ;;
#             divide)
#                 read -p "Enter the first number: " n1
#                 read -p "Enter the second number: " n2
#                 echo "$n1 / $n2 = $(($n1/$n2))"
#                 break
#                 ;;
#             quit)
#                 break
#                 ;;
#             *) 
#                 echo "Invalid option $REPLY"
#                 ;;
#         esac
#     done
# }
