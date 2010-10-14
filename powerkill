#!/bin/bash

set -e

if [ -z $1 ]  ; then 
	exit 2
fi

pids=$(ps -elf | grep $1 | grep -v grep | awk '{print $4}')

for pid in ${pids} ; do
	kill -9 $pid
done
