#!/bin/bash

# script asks about minimal space 
# checks space every 60 secs 
# when free space is lower than minimal space shows warning and stops 

read -p "Please write a number, that defines minimal free space threshold in GB: " threshold 

if [ -z "$threshold" ]
then
  threshold=$(( 10*1024*1024 )) 
else 
  threshold=$(( $threshold*1024*1024 ))
fi

while true; do
  free_space=$(df / | awk 'NR==2 {print $4}')
  if [ $threshold -gt $free_space ]; then 
    echo "Warning: free disk space is below ${threshold}G"
    break;
  else 
    echo "Everything is okay"
  fi 
	
  sleep 60
done
