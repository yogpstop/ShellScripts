#!/bin/bash
if [[ "${UID}" -ne "0" ]] ; then
	sudo $0
	exit $?
fi
echo "You should reboot this computer after installation."
read -p "Do you want to reboot this computer after installation automatically?[y/N]" -n1 reboot
echo
mkdir "/emul/ia32-linux/usr"
ln -s "/usr/lib/i386-linux-gnu" "/emul/ia32-linux/usr/lib"
./NVIDIA-*
update-rc.d gdm3 defaults
if [ "${reboot}" = "y" -o "${reboot}" = "Y" ] ; then
	reboot
fi
