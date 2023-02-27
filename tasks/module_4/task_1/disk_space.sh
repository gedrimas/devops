#!/bin/bash

# set default threshold value if no command line argument is given
if [ -z "$1" ]; then
  threshold=10  # default threshold is 10%
else
  threshold=$1
fi

# loop indefinitely and check disk space every 10 seconds
while true; do
  free_space=$(df / | awk '/\//{print $(NF-1)}')  # get percentage of free space on root directory
  echo "current free disk space: $free_space"
  free_space=${free_space/%%/}
  if [ "$free_space" -lt "$threshold" ]; then
    echo "WARNING: Free disk space is below ${threshold}%"
  fi
  sleep 10  # wait 10 seconds before checking again
done

