#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pyinotify
import os
import subprocess

watch_dir = "/home/mathieu/Sites/boesner/web/css/"

wm = pyinotify.WatchManager()
mask = pyinotify.IN_MODIFY
class EventHandler(pyinotify.ProcessEvent):
    def process_IN_MODIFY(self, event):
        if not event.pathname.endswith('.less'):
            return
        
        #subprocess.call(['lessc', event.pathname])

handler = EventHandler()
notifier = pyinotify.Notifier(wm, handler)
wdd = wm.add_watch(watch_dir, mask, rec=True)

notifier.loop()



