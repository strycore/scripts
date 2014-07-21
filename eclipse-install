#!/bin/bash

destdir=/opt/
if [ ! "$1" ]; then
    echo "Please specify path to Eclipse archive."
    echo "Usage: eclipse-install eclipse-….tar.gz"
    exit 2
fi

echo "Extracting $1"
cd $destdir
tar xzf $1

cd ~/.local/share/applications/

(
cat <<EOF
[Desktop Entry]
Comment=
Terminal=false
Name=Eclipse
Exec=${destdir}eclipse/eclipse
Type=Application
Icon=eclipse
EOF
) > eclipse.desktop
