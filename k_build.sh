#!/bin/bash
path="/pub/linux/kernel/projects/rt"
list=(`echo -e "open ftp.kernel.org\nuser anonymous guest\n ls ${path} -\nexit" | ftp -n | sed -e "s/^.* \([^ ]*\) *$/\1/g"`)
num=-1
cnt=`expr ${#list[@]} - 1`
for i in `seq 0 ${cnt}` ; do
  echo $i ${list[$i]}
done
while test -z "${num}" || [ ${num} -ge ${#list[@]} -o ${num} -lt 0 ] ; do
  echo -n "Select version : "
  read num
done
path+="/${list[${num}]}"
list=(`echo -e "open ftp.kernel.org\nuser anonymous guest\n ls ${path} -\nexit" | ftp -n | sed -e "s/^.* \([^ ]*\) *$/\1/g" | grep -E "patch-.*\.patch\.xz$"`)
num=0
if [ ${#list[@]} -ne 1 ] ; then
  num=-1
  cnt=`expr ${#list[@]} - 1`
  for i in `seq 0 ${cnt}` ; do
    echo $i ${list[$i]}
  done
  while test -z "${num}" || [ ${num} -ge ${#list[@]} -o ${num} -lt 0 ] ; do
    echo -n "Select version : "
    read num
  done
fi
filename="linux-"
filename+=`echo "${list[${num}]}" | sed -e "s/^patch-\(.*\)-rt.*\.patch\.xz$/\1/"`
path+="/${list[${num}]}"
wget -O patch.xz "ftp://ftp.kernel.org${path}"
path="ftp://ftp.kernel.org/pub/linux/kernel/v3.x/${filename}.tar.xz"
wget -O linux.tar.xz "${path}"
tar xf linux.tar.xz
rm -f linux.tar.xz
cd ${filename}
xzcat ../patch.xz | patch -p1 -s
rm -f ../patch.xz
cp /boot/config-$(uname -r) .config
make silentoldconfig
make menuconfig
echo -n "Please type revision number: "
read revision
if [ -z "${revision}" ] ; then
revision="--revision=${revision}"
fi
make-kpkg clean
CONCURRENCY_LEVEL=12
export CONCURRENCY_LEVEL
start=`date "+%s.%N"`
fakeroot make-kpkg ${revision} --initrd kernel_image kernel_headers
end=`date "+%s.%N"`
cd ..
rm -rf ${filename}
echo `echo -e "scale=9\n${end}-${start}" | bc`
