#!/bin/sh

script_dir=$(dirname $0)

alock -auth pam -bg image:file=$script_dir'/../Pictures/lockscreen.jpg',shade=30
