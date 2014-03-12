#!/bin/bash
KERNEL_BASE_VERSION=3.12
KERNEL_VERSION=${KERNEL_BASE_VERSION}.10
KERNEL_RELEASE=300.fc20
RT_RELEASE=15

sudo yum install -y yum wget yum-utils bash coreutils rpmdevtools rpm sed patch rpm-build

BASE=`dirname \`readlink -mqsn "$0"\``
cd
wget "http://kojipkgs.fedoraproject.org/packages/kernel/${KERNEL_VERSION}/${KERNEL_RELEASE}/src/kernel-${KERNEL_VERSION}-${KERNEL_RELEASE}.src.rpm"
rm -rf rpmbuild
rpmdev-setuptree
rpm -Uvh kernel-*.src.rpm
if [[ $1 == --check ]] ; then
	cat ${BASE}/diff | sed -e "s/%RT_RELEASE%/${RT_RELEASE}/g" | sed -e "s/%KERNEL_VERSION%/${KERNEL_VERSION}/g" | patch -p1 -F0 --dry-run --verbose >${BASE}/diff_report
else
	cat ${BASE}/diff | sed -e "s/%RT_RELEASE%/${RT_RELEASE}/g" | sed -e "s/%KERNEL_VERSION%/${KERNEL_VERSION}/g" | patch -p1
	sudo yum-builddep -y kernel-*.src.rpm
	cd rpmbuild/SOURCES
	if ! wget "https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_BASE_VERSION}/patch-${KERNEL_VERSION}-rt${RT_RELEASE}.patch.xz" ; then
		wget "https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_BASE_VERSION}/older/patch-${KERNEL_VERSION}-rt${RT_RELEASE}.patch.xz"
	fi
	cd
	rpmbuild -bb --target=x86_64 rpmbuild/SPECS/kernel.spec
fi
rm kernel-*.src.rpm
