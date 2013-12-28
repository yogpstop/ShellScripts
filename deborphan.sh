#!/bin/bash
deborphan -k deborphan.list -A ntpdate deborphan #correctTime,PackageManager
deborphan -k deborphan.list -A xserver-xorg-video-intel xserver-xorg-video-vesa
deborphan -k deborphan.list -A xserver-xorg xinit #X11
deborphan -k deborphan.list -A lxde-common lxpanel lxterminal pcmanfm libgnome2-0 #GNOME
deborphan -k deborphan.list -A gdm3 lightdm openbox
deborphan -k deborphan.list -A ibus-mozc im-switch fontforge #JapaneseInput
deborphan -k deborphan.list -A gparted ntfsprogs dosfstools e2fsprogs #Partitioning
deborphan -k deborphan.list -A alsa-base alsa-utils flac mplayer geeqie audacity gimp #Multimedia
deborphan -k deborphan.list -A leafpad vim ghex git subversion mercurial astyle #programming
deborphan -k deborphan.list -A python-gpgme #networking
deborphan -k deborphan.list -A kernel-package fakeroot libncurses5-dev bc ftp #kernelBuild
deborphan -k deborphan.list -A p7zip-full p7zip-rar #Archive Utils
deborphan -k deborphan.list -A libgl1-mesa-glx libgl1-mesa-dri
deborphan -k deborphan.list -A openssh-server x11vnc openssh-client
###########################################################################
deborphan -k deborphan.list -A isc-dhcp-client busybox rsyslog iptables
deborphan -k deborphan.list -A acpi-support-base net-tools grub-pc
deborphan -k deborphan.list -A console-setup traceroute locales os-prober
deborphan -k deborphan.list -A linux-image-`uname -r` linux-headers-`uname -r`
deborphan -k deborphan.list -A ifupdown pciutils sudo initramfs-tools man-db
deborphan -k deborphan.list -A manpages nkf dnsutils acpi
deborphan -k deborphan.list -A iputils-ping automake discover eject info

deborphan --no-show-section -aHn --guess-all -k deborphan.list
rm -f deborphan.list
