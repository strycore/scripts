#!/bin/bash

DEST=/tmp/soundcard-info
mkdir -p $DEST

cp /var/log/pm-suspend.log $DEST
lspci -nn | egrep  'sound|udio' > $DEST/lspci.out
cp /proc/asound/cards > $DEST/cards
pulseaudio --check
echo "$?" > $DEST/pulse_running
lsmod > $DEST/modules

tar cvzf ~/sound-info.tar.gz $DEST
