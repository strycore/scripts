#!/bin/bash


#sudo apt-get install dh-make devscripts cdbs build-essential fakeroot

PKGNAME="buuf-icon-theme"
VER="1.1"
SOURCE_DIR="$HOME/dev/buufdeuce-1.1/"
PKG_DIR="$HOME/dev/packaging/"$PKGNAME"-"$VER
SECTION="x11"
PRIORITY="optional"
PROJECTURL="http://djany.deviantart.com/art/Gnome-Buuf-Deuce-1-1-R3-73339997"
PROJECTDESC="gnome-buuf iconset with the Deuce iconset fron Mattahan"
PROJECTLONGDESC=""
DEPENDS=""
export DEBFULLNAME="Mathieu Comandon"
export DEBEMAIL="strycore@gmail.com"
rm -rf $PKG_DIR
mkdir -p $PKG_DIR
cd $PKG_DIR

cp $SOURCE_DIR/* $PKG_DIR -R
tar cvzf ../${PKGNAME}"_"${VER}.orig.tar.gz ../${PKGNAME}-${VER}/
dh_make -c artistic -s

cd debian
rm *ex *EX README.Debian dirs


#control file
sed -i -e 's|Homepage: .*|Homepage: '$PROJECTURL'|' control
sed -i -e 's|Architecture: .*|Architecture: all|' control
sed -i -e 's|Section: .*|Section: '$SECTION'|' control
sed -i -e 's|Priority: .*|Priority: '$PRIORITY'|' control
sed -i -e 's|Description: .*|Description: '"$PROJECTDESC"'|' control
sed -i -e 's| <insert long desc.*|'"$PROJECTLONGDESC"'|' control
sed -i -e 's|Depends: ${shlibs:Depends}, ${misc:Depends}|Depends: '"$DEPENDS"' ${misc:Depends}|' control
sed -i -e 's|Build-Depends: .*|&|' control

#rules file

sed -i -e 's|$(MAKE)$|& DESTDIR=$(CURDIR)/debian/buuf-icon-theme|' rules

#copyright
#TODO : put the copyright stuff here

#Changelog
sed -i -e "s/unstable/jaunty/" changelog
sed -i -e "s|\(Initial release\).*|\1|" changelog

cd ..
debuild -S -sa
#dpkg-buildpackage -us -uc
pwd
