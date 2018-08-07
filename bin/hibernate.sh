#!/bin/sh

script_dir=$(dirname $0)

($script_dir/lock.sh &) && sleep 1 && sudo s2ram

