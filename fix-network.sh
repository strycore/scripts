#!/bin/bash

SUDO='gksu'
ECHO='zenity --info --text='
GATEWAY_IP=192.168.0.1


WLAN_CONNECTED=`ifconfig | grep "^wlan0" | wc -l`
if [ $WLAN_CONNECTED = 0 ]
    then
    $ECHO"Please connect WIFI Dongle"
    exit 2
fi

$SUDO ifconfig eth0 down
$SUDO ifconfig eth0 192.168.2.103 netmask 255.255.255.0 up
$SUDO route del  default gw $GATEWAY_IP eth0
$SUDO route add  default gw $GATEWAY_IP wlan0

if [  $(ping -c 1 wanadoo.fr  | grep "64 bytes from" | wc -l) = 1 ] ; then
    $ECHO"Connected to the interwebz !"
fi

if [  $(ping -c 1 newport  | grep "64 bytes from" | wc -l) = 1 ] ; then
    $ECHO"Connected to the localz !"
    if [ $(ls /mnt/music | wc -l) = 0 ] ; then
        $SUDO mount /mnt/music
    fi
fi

