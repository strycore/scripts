#!/usr/bin/env python
# Filename: psd-thumbnailer.py

__licence__ = "LGPLv3"
__copyright__ = "Matthew McGowan, 2008"
__author__ = "Matthew McGowan <matthew.joseph.mcgowan@gmail.com>"

import sys
from PIL import Image

cwd, maxxy, infile, outfile = sys.argv
size = int(maxxy), int(maxxy)

#logfile = open('/home/mathieu/psd.log', 'a')
#logfile.write("Writing thumb for psd file : %s \n" % infile)
#logfile.close()

im = Image.open(infile)
im.thumbnail(size, Image.ANTIALIAS)
im.save(outfile, "PNG")

