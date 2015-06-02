#!/bin/bash

IFS=$'\n'
set -e


echo "Using key $1"
pgp_key=$1
shift

echo "Moving secure files to $1"
mkdir -p $1
cd $1
shift

for f in $@; do
    echo $f
    arch_name="$(uuid -v 5 ns:URL "$f").tar"
    tar cf ${arch_name} $f
    gpg -r ${pgp_key} -e ${arch_name}
    rm ${arch_name}
done
