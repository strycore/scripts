#!/bin/bash
set -e

arch=$(uname -m)
version="2016-1-17"

if [ ! "$1" ]; then
    echo "Please specify the path to the latest Soulseek archive downloaded from Dropbox"
    exit 2
fi

if [ $arch = 'x86_64' ]; then
    exec_suffix='-64bit'
else
    exec_suffix=''
fi

dest_path="/opt/soulseek/"
sudo mkdir -p $dest_path
slsk_archive="/tmp/soulseek-client.tar.gz"
cp $1 "${slsk_archive}"
cd $dest_path
sudo tar xzf ${slsk_archive}
rm "${slsk_archive}"

desktop_path="$HOME/.local/share/applications/"
cd "$desktop_path"

(
cat <<EOF
[Desktop Entry]
Comment=
Terminal=false
Name=Soulseek
Exec=${dest_path}SoulseekQt-${version}${exec_suffix}
Type=Application
Icon=soulseek
EOF
) > soulseek.desktop
chmod +x soulseek.desktop
update-desktop-database $desktop_path
