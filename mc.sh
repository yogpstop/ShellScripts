#!/bin/bash
lwjgl="${HOME}/lwjgl-2.9.0"
listdir="/d/Minecraft/"

case `uname -s` in
  *FreeBSD ) osdir="freebsd"
  mcdir="${HOME}/.minecraft" ;;
  Linux ) osdir="linux"
  mcdir="${HOME}/.minecraft" ;;
  Darwin ) osdir="macosx"
  mcdir="${HOME}/Library/Application Support/.minecraft" ;;
  SunOS ) osdir="solaris"
  mcdir="${HOME}/.minecraft" ;;
  CYGWIN* | MINGW* | UWIN* ) osdir="windows"
  mcdir="${APPDATA}/.minecraft"
  windows="YES" ;;
esac

drs=(`find "${listdir}" -maxdepth 1 -mindepth 1 -type d -exec test -f "{}/minecraft.jar" \; -print | sed -e "s~${listdir}~~"`)
cnt=`expr ${#drs[@]} - 1`
num=-1
for i in `seq 0 ${cnt}` ; do
  echo $i ${drs[$i]}
done
while test -z "${num}" || test "${num}" -ge ${#drs[@]} -o "${num}" -lt 0 ; do
  read -p "Select directory: " num
done

basedir="${listdir}${drs[$num]}"

rm -rf "${mcdir}"
if [ "${windows}" = "YES" ] ; then
  mkdir "${mcdir}"
  cd "${mcdir}"
  mcdirw=`cmd /c cd`
  mcdir=`pwd`
  cd "${basedir}"
  rm -rf "${mcdir}"
  basedirw=`cmd /c cd`
  trap "cmd /c \"rmdir \\\"${mcdirw}\\\"\"" EXIT
  cmd /c "mklink /d \"${mcdirw}\" \"${basedirw}\"" >/dev/null
else
  trap 'rm "${mcdir}"' EXIT
  ln -s "${basedir}" "${mcdir}"
fi

if [ "${drs[$num]}" = "Official" ] ; then
  java -jar "${mcdir}/minecraft.jar"
  exit
fi

drs=(`ls "${listdir}.users/"`)
cnt=`expr ${#drs[@]} - 1`
num=-1
for i in `seq 0 ${cnt}` ; do
  echo $i ${drs[$i]}
done
while  test -z "${num}" || test "${num}" -ge ${#drs[@]} -o "${num}" -lt 0 ; do
  read -p "Select username: " num
done
user="${drs[$num]}"
pass=`openssl enc -d -aes-256-cfb8 -in "${listdir}.users/${user}"`

ary=(`wget -q --no-check-certificate --post-data "user=${user}&password=${pass}&version=16" https://login.minecraft.net -O - | tr ':' ' '`)

java -Xms2G -Xmx4G -cp "${mcdir}/minecraft.jar:${lwjgl}/jar/lwjgl.jar:${lwjgl}/jar/lwjgl_util.jar:${lwjgl}/jar/jinput.jar" \
-Djava.library.path="${lwjgl}/native/${osdir}" net.minecraft.client.Minecraft ${ary[2]} ${ary[3]}
