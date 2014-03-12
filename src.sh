#!/bin/bash
for a in `dpkg -l | grep -E "^ii" | sed -e "s/^ii  \([^ ]\+\) \+[^ ]\+ \+[^ ]\+ \+.\+/\1/" | tr '\n' ' '` ; do
    b=`echo -n "${a}" | sed -e "s/:.\+//"`
    if [ "`apt-cache showsrc "${b}" 2>/dev/null | grep "Package: " | sed -e "s/Package: //"`" = "$1" ] ; then
        echo ${a}
    fi
done
