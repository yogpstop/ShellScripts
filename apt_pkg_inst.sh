#!/bin/bash
echo -n "you want to install OpenSSH server?[y/N] "
read sshd
echo -n "do you use intel video card?[y/N] "
read intel
if [ "`grep -i ubuntu /etc/issue`" != "" ] ; then
	dest="ubuntu"
fi
if [ "`grep -i debian /etc/issue`" != "" ] ; then
	dest="debian"
fi
if [ "${dest}" = "" ] ; then
	echo "Script cannot detect destribution"
	exit 1
fi
packages="ntpdate deborphan" #correctTime,PackageManager
if [ "${intel}" = "y" -o "${intel}" = "Y" ] ; then
	packages+=" xserver-xorg-video-intel"
else
	packages+=" xserver-xorg-video-vesa"
fi
packages+=" xserver-xorg xinit" #X11
if [ "${dest}" = "ubuntu" ] ; then
	packages+=" gdm3"
else
	packages+=" gdm"
fi
packages+=" gnome-session-fallback gnome-terminal nautilus libgnome2-0" #GNOME
packages+=" ibus-mozc im-switch" #JapaneseInput
packages+=" gparted ntfsprogs dosfstools mtools e2fsprogs" #Partitioning
packages+=" alsa-base alsa-utils flac mplayer geeqie audacity gimp" #Multimedia
packages+=" leafpad vim ghex git astyle" #programming
packages+=" google-chrome-stable python-gpgme dropbox transmission-gtk" #networking
packages+=" kernel-package fakeroot libncurses5-dev" #kernelBuild
packages+=" p7zip-full p7zip-rar" #Archive Utils
if [ "${sshd}" = "y" -o "${sshd}" = "Y" ] ; then
	packages+=" openssh-server"
else
	packages+=" openssh-client"
fi

if [ "${dest}" = "ubuntu" ] ; then
	echo "deb http://linux.dropbox.com/ubuntu/ precise main" >"/etc/apt/sources.list.d/yogpstop_dpi.list"
else
	echo "deb http://linux.dropbox.com/debian/ wheezy main" >"/etc/apt/sources.list.d/yogpstop_dpi.list"
fi
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >>"/etc/apt/sources.list.d/yogpstop_dpi.list"

apt-get -y --purge --no-install-recommends update
apt-get -y --purge --no-install-recommends dist-upgrade
apt-get -y --purge --no-install-recommends install ${packages}
apt-get -y --purge --no-install-recommends autoremove
apt-get -y clean

echo net.ipv6.conf.all.disable_ipv6=1 >/etc/sysctl.d/disableipv6.conf
