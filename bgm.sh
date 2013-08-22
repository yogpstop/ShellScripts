#!/bin/bash
stty -echo
trap "stty echo" EXIT
IFS='
'
for arg in "$@" ; do
  arg=`readlink -mq "${arg}"`
  if [ ${arg} == *.flac ] ; then
    fl+=(${arg})
  elif [ -d "${arg}" ] ; then
    fl+=(`find "${arg}" -type f -iname "*.flac"`)
  elif [ -f "${arg}" ] ; then
    bdir=`dirname "${arg}"`
    while read line ; do
      line=`readlink -mq "${bdir}/${line}"`
      if [ -f "${line}" -a "${line##*.}" = "flac" ] ; then
        fl+=(${line})
      fi
    done <"${arg}"
  fi
done
trap '' SIGINT
fl=(`echo "${fl[*]}" | shuf`)
for line in "${fl[@]}" ; do
  str=${line##*/}
  echo "Now playing... ${str%.*}"
  flac -cds "${line}" | chrt -r 98 dd ibs=2G iflag=fullblock 2>/dev/null | chrt -r 99 aplay -D hw:CODEC -q -
done
exit 0

