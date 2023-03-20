#!/bin/bash

# shows number of file in giver directory and subdirectories
# run with path to folder (or several paths to folder)

if [ -z "$1" ]; then
  echo "Please provide at least one directory path"
  exit 1
fi

for directory in "$@"; do
  if [ ! -d "$directory" ]; then
    echo "$directory is not found"
    exit 1
  fi

  file_count=$(find "$directory" -type f | wc -l)
  echo "$directory: $file_count"
done