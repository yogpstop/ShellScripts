#!/bin/bash
###########################################################################
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
deborphan -k deborphan.list -A ntpdate deborphan #correctTime,PackageManager
deborphan -k deborphan.list -A xserver-xorg-video-intel xserver-xorg-video-vesa
deborphan -k deborphan.list -A xserver-xorg xinit #X11
if [ "${dest}" = "ubuntu" ] ; then
	deborphan -k deborphan.list -A gdm
else
	deborphan -k deborphan.list -A gdm3
fi
deborphan -k deborphan.list -A gnome-session-fallback gnome-terminal nautilus libgnome2-0 #GNOME
deborphan -k deborphan.list -A ibus-mozc im-switch #JapaneseInput
deborphan -k deborphan.list -A gparted ntfsprogs dosfstools mtools e2fsprogs #Partitioning
deborphan -k deborphan.list -A alsa-base alsa-utils flac mplayer geeqie audacity gimp #Multimedia
deborphan -k deborphan.list -A leafpad vim ghex git astyle #programming
deborphan -k deborphan.list -A google-chrome-stable python-gpgme dropbox transmission-gtk #networking
deborphan -k deborphan.list -A kernel-package fakeroot libncurses5-dev #kernelBuild
deborphan -k deborphan.list -A p7zip-full p7zip-rar #Archive Utils
deborphan -k deborphan.list -A openssh-server openssh-client
###########################################################################
deborphan -k deborphan.list -A cups isc-dhcp-client busybox rsyslog iptables discover eject info nasm acpi
deborphan -k deborphan.list -A acpi-support-base smbclient net-tools fbterm grub-pc task-japanese
deborphan -k deborphan.list -A logrotate console-setup traceroute locales os-prober shntool
deborphan -k deborphan.list -A linux-image-`uname -r` linux-headers-`uname -r` usbutils
deborphan -k deborphan.list -A ifupdown pciutils sudo initramfs-tools man-db nkf dnsutils libav-tools
deborphan -k deborphan.list -A firmware-realtek sqlite3 muse manpages-ja-dev libgtk-3-dev manpages libssl-dev
deborphan -k deborphan.list -A iputils-ping automake libsqlite3-dev gvfs-backends

deborphan --no-show-section -aHn --guess-all -k deborphan.list
rm -f deborphan.list