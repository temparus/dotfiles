#!/bin/sh

script_dir=$(dirname $0)

($script_dir/lock.sh &) && sudo hibernate-ram
