#!/bin/sh

set -e

. $(dirname "$0")/raid_manage.config.sh

for i in `seq 0 1`
do
    mdadm --stop /dev/md/${MD_NAME}_$i
done

losetup --list           |
grep $PREFIX             |
cut -f 1 -d ' '          |
while read lodevice
do
    losetup -d $lodevice
done

for i in `seq 5`
do
    rm $PREFIX.$i.raw
done

exit 0
