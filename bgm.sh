#!/bin/bash
stty -echo
trap "stty echo" EXIT
IFS='
'
for arg in "$@" ; do
  arg=`readlink -mq "${arg}"`
  if [[ "${arg}" =~ .*\.[Ff][Ll][Aa][Cc] ]] ; then
    fl+=(${arg})
  elif [[ "${arg}" =~ .*\.[Ww][Aa][Vv] ]] ; then
    fl+=(${arg})
  elif [ -d "${arg}" ] ; then
    fl+=(`find "${arg}" -type f -iname "*.flac"`)
  elif [ -f "${arg}" ] ; then
    bdir=`dirname "${arg}"`
    while read line ; do
      line=`readlink -mq "${bdir}/${line}"`
      if [ -f "${line}" ] && [[ "${line}" =~ .*\.[Ff][Ll][Aa][Cc] ]] ; then
        fl+=(${line})
      fi
    done <"${arg}"
  fi
done
fl=(`echo "${fl[*]}" | shuf`)
for line in "${fl[@]}" ; do
  str=${line##*/}
  echo "Now playing... ${str%.*}"
  if [[ "${line}" =~ .*\.[Ff][Ll][Aa][Cc] ]] ; then
    flac -cds "${line}" | chrt -r 98 dd ibs=2G iflag=fullblock 2>/dev/null | \
      chrt -r 99 aplay -D rt -q --period-size=48 --buffer-size=144 - && \
      kill -SIGINT `ps | grep "cat" | sed -e "s/ \([0-9]*\).*/\1/"` &>/dev/null &
  elif [[ "${line}" =~ .*\.[Ww][Aa][Vv] ]] ; then
    chrt -r 98 dd "if=${line}" ibs=2G iflag=fullblock 2>/dev/null | \
      chrt -r 99 aplay -D rt -q --period-size=48 --buffer-size=144 - && \
      kill -SIGINT `ps | grep "cat" | sed -e "s/ \([0-9]*\).*/\1/"` &>/dev/null &
  fi
  cat
  kill -SIGINT `ps | grep -E "aplay|flac|dd|chrt" | \
    sed -e "s/ \([0-9]*\).*/\1/"` &>/dev/null
  wait `ps | grep "aplay" | sed -e "s/ \([0-9]*\).*/\1/"`
done
exit 0
