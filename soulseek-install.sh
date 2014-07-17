arch=$(uname -i)

if [ $arch = 'x86_64' ]; then
    slsk_url="http://www.soulseekqt.net/SoulseekQT/Linux/SoulseekQt-2013-11-6-64bit.tgz"
    exec_suffix='-64bit'
else
    slsk_url="http://www.soulseekqt.net/SoulseekQT/Linux/SoulseekQt-2013-11-6.tgz"
    exec_suffix=''
fi

dest_path="/opt/soulseek/"
mkdir -p $dest_path
slsk_archive="soulseek-client.tar.gz"
wget $slsk_url -O ${dest_path}${slsk_archive}
cd $dest_path
tar xzf ${slsk_archive}
rm ${slsk_archive}

cd ~/.local/share/applications/

(
cat <<EOF
[Desktop Entry]
Comment=
Terminal=false
Name=Soulseek
Exec=${dest_path}SoulseekQt-2013-11-6${exec_suffix}
Type=Application
Icon=soulseek
EOF
) > soulseek.desktop
