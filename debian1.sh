#!/bin/bash
if [[ "${UID}" -ne "0" ]] ; then
	sudo $0
	exit $?
fi
read -p "Do you want to install OpenSSH server?[y/N]" -n1 sshd
echo
read -p "Do you use intel video card?[y/N]" -n1 intel
echo
read -p "Do you want to use gnome display manager?[y/N]" -n1 gdm
echo
read -p "Do you want to install OpenGL libraries?[y/N]" -n1 ogl
echo
echo "You should reboot this computer after installation."
read -p "Do you want to reboot this computer after installation automatically?[y/N]" -n1 reboot
echo
packages="ntpdate deborphan" #correctTime,PackageManager
if [ "${intel}" = "y" -o "${intel}" = "Y" ] ; then
	packages+=" xserver-xorg-video-intel"
else
	packages+=" xserver-xorg-video-vesa"
fi
packages+=" xserver-xorg xinit" #X11
packages+=" lxde-common lxpanel lxterminal pcmanfm libgnome2-0" #GNOME
if [ "${gdm}" = "y" -o "${gdm}" = "Y" ] ; then
	packages+=" gdm3"
else
	packages+=" lightdm openbox lxpolkit policykit-1"
fi
packages+=" ibus-mozc im-switch fontforge" #JapaneseInput
packages+=" gparted ntfsprogs dosfstools e2fsprogs" #Partitioning
packages+=" alsa-base alsa-utils flac mplayer geeqie audacity gimp" #Multimedia
packages+=" leafpad vim ghex git subversion mercurial astyle" #programming
packages+=" python-gpgme" #networking
packages+=" kernel-package fakeroot libncurses5-dev bc ftp" #kernelBuild
packages+=" p7zip-full p7zip-rar" #Archive Utils
if [ "${ogl}" = "y" -o "${ogl}" = "Y" ] ; then
	packages+=" libgl1-mesa-glx libgl1-mesa-dri libgl1-mesa-glx:i386 libgl1-mesa-dri:i386" #Graphics
fi
if [ "${sshd}" = "y" -o "${sshd}" = "Y" ] ; then
	packages+=" openssh-server x11vnc"
else
	packages+=" openssh-client"
fi

dpkg --add-architecture i386
apt-get -y update
apt-get -y --purge --no-install-recommends dist-upgrade
apt-get -y --purge --no-install-recommends autoremove
apt-get -y --purge --no-install-recommends install ${packages}
apt-get -y clean

wget -O "skype.deb" "http://www.skype.com/go/getskype-linux-deb-32"
wget -O "chrome.deb" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
wget -O "steam.deb" "http://media.steampowered.com/client/installer/steam.deb"
wget -O "dropbox.deb" "https://linux.dropbox.com/packages/debian/dropbox_1.6.0_amd64.deb"
dpkg -i "skype.deb" "chrome.deb" "steam.deb" "dropbox.deb"
rm "skype.deb" "chrome.deb" "steam.deb" "dropbox.deb"
apt-get -y --purge --no-install-recommends -f install

echo net.ipv6.conf.all.disable_ipv6=1 >/etc/sysctl.d/disableipv6.conf
update-rc.d gdm3 remove
dpkg -i linux-*.deb
if [ "${gdm}" = "y" -o "${gdm}" = "Y" ] ; then
	sed -ie "s/^window_manager=.*$/window_manager=metacity/" "/etc/xdg/lxsession/LXDE/desktop.conf"
fi
echo -en "Section \"InputClass\"\n    Identifier \"DeathAdder\"\n    MatchIsPointer \"true\"\n    Option \"AccelerationProfile\" \"-1\"\n    Option \"ConstantDeceleration\" \"16\"\nEndSection\n" >/etc/X11/xorg.conf.d/99-DeathAdder.conf
echo -en "UUID=B276286E7628358F /media/DATA ntfs-3g defaults 0 0\n" >/etc/fstab.d/DATA.fstab
echo -en "UUID=7fa84ded-20cb-4030-9922-6fcf45d5a00d /media/LD ext4 defaults 0 0\n" >/etc/fstab.d/LD.fstab
mkdir "/media/DATA" "/media/LD"
if [ "${reboot}" = "y" -o "${reboot}" = "Y" ] ; then
	reboot
fi
