#!/bin/bash

set -e

PGP_KEY=2570D912
PPA_ID=strycore/cdemu
DIST=$(lsb_release -sc)
source_dir="cdemu-code"

sudo apt-get install -y debhelper devscripts gobject-introspection

if [ -d ${source_dir} ]; then
    cd ${source_dir}
    rm -f *.dsc *_source.build *.changes *.upload *.orig.tar.gz *.debian.tar.xz
    git reset --hard
else
    git clone git://git.code.sf.net/p/cdemu/code ${source_dir}
    cd ${source_dir}
fi

tar czf cdemu-client_3.0.0.orig.tar.gz cdemu-client
cd cdemu-client
dch -i --distribution $DIST "Update Ubuntu version"
debuild -S -sa -k${PGP_KEY}
cd ..

tar czf cdemu-daemon_3.0.2.orig.tar.gz cdemu-daemon
cd cdemu-daemon
dch -i --distribution $DIST "Update Ubuntu version"
debuild -S -sa -k${PGP_KEY}
cd ..

tar czf gcdemu_3.0.0.orig.tar.gz gcdemu
cd gcdemu
dch -i --distribution $DIST "Update Ubuntu version"
debuild -S -sa -k${PGP_KEY}
cd ..

tar czf image-analyzer_3.0.0.orig.tar.gz image-analyzer
cd image-analyzer
dch -i --distribution $DIST "Update Ubuntu version"
debuild -S -sa -k${PGP_KEY}
cd ..

tar czf libmirage_3.0.3.orig.tar.gz libmirage
cd libmirage
dch -i --distribution $DIST "Update Ubuntu version"
debuild -S -sa -k${PGP_KEY}
cd ..

tar czf vhba-module_20140928.orig.tar.gz vhba-module
cd vhba-module
dch -i --distribution $DIST "Update Ubuntu version"
debuild -S -sa -k${PGP_KEY}
cd ..

dput ppa:${PPA_ID} cdemu-client_3.0.0-1ubuntu1_source.changes
dput ppa:${PPA_ID} gcdemu_3.0.0-1ubuntu1_source.changes
dput ppa:${PPA_ID} libmirage_3.0.3-1ubuntu1_source.changes
dput ppa:${PPA_ID} cdemu-daemon_3.0.2-1ubuntu1_source.changes
dput ppa:${PPA_ID} image-analyzer_3.0.0-1ubuntu1_source.changes
dput ppa:${PPA_ID} vhba-module_20140928-1ubuntu1_source.changes
