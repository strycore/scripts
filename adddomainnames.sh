#!/bin/bash
for i in $(seq 97105 99999) ; do

    hash=$(echo $i | md5sum)
    wget "http://adddomainnames.com/first.php?di=$i&hash=$hash" -O /dev/null

done

