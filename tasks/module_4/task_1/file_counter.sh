#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 directory1 directory2 ..." >&2
  exit 1
fi

for dir in "$@"; do
  echo "Counting files in directory: $dir"
  count=$(find "$dir" -type f | wc -l)
  echo "Number of files: $count"
done

