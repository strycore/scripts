#!/bin/bash
# Resources
# http://www.gimpusers.com/tutorials/compiling-gimp-for-ubuntu
# http://ubuntuforums.org/showthread.php?p=11818979
#

sudo apt-get build-dep gimp
sudo apt-get install libjpeg62-dev libopenexr-dev librsvg2-dev libtiff4-dev

mkdir gimp_build && cd gimp_build

version="2.9"
destdir="/opt/gimp-${version}"
export PATH=/opt/gimp-2.8/bin:$PATH
export PKG_CONFIG_PATH=/opt/gimp-2.8/lib/pkgconfig
export LD_LIBRARY_PATH=/opt/gimp-2.8/lib
CPU_CORES=$(grep -c processor /proc/cpuinfo)

git clone git://git.gnome.org/babl
cd babl
./autogen.sh --prefix=/opt/gimp-2.8
make -j${CPU_CORES}
sudo make install

cd ..
git clone git://git.gnome.org/gegl
cd gegl
./autogen.sh --prefix=/opt/gimp-2.8
./configure  --prefix=/opt/gimp-2.8
make -j${CPU_CORES}
sudo make install

cd ..
git clone git://git.gnome.org/gimp
cd gimp
./autogen.sh --prefix=/opt/gimp-2.8
./configure --prefix=/opt/gimp-2.8
make -j${CPU_CORES}
sudo make install

cat << EOF > ~/.local/share/applications/gimp2.8RC1.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Gimp 2.8
Comment=Create images and edit photographs
Exec=/opt/gimp-2.8/bin/gimp-2.8 %U
TryExec=/opt/gimp-2.8/bin/gimp-2.8
Icon=gimp
Terminal=false
Categories=Graphics;2DGraphics;RasterGraphics;GTK;
X-GNOME-Bugzilla-Bugzilla=GNOME
X-GNOME-Bugzilla-Product=GIMP
X-GNOME-Bugzilla-Component=General
X-GNOME-Bugzilla-Version=2.8.0-RC1
X-GNOME-Bugzilla-OtherBinaries=gimp-2.8
MimeType=application/postscript;application/pdf;image/bmp;image/g3fax;image/gif;image/x-fits;image/pcx;image/x-portable-anymap;image/x-portable-bitmap;image/x-portable-graymap;image/x-portable-pixmap;image/x-psd;image/x-sgi;image/x-tga;image/x-xbitmap;image/x-xwindowdump;image/x-xcf;image/x-compressed-xcf;image/x-gimp-gbr;image/x-gimp-pat;image/x-gimp-gih;image/tiff;image/jpeg;image/x-psp;image/png;image/x-icon;image/x-xpixmap;image/svg+xml;application/pdf;image/x-wmf;image/jp2;image/jpeg2000;image/jpx;image/x-xcursor;
EOF

chmod +x ~/.local/share/applications/gimp2.8RC1.desktop
