#!/bin/bash

function get_focus_id()
{
    wid=`xprop -root _NET_ACTIVE_WINDOW | grep "_NET_ACTIVE_WINDOW(WINDOW)" | awk '{print $5}'`
    xprop -id $wid | grep CLASS
}

while [ "yes" ]
do
    sleep 1
    get_focus_id
done
