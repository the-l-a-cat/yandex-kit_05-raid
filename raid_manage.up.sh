#!/bin/sh

set -e

. $(dirname "$0")/raid_manage.config.sh

for i in `seq 5`
do
    fallocate -l $RAID_SIZE $PREFIX.$i.raw
done

for i in `seq 5`
do
    losetup --find --show $PREFIX.$i.raw
done

for i in `seq 0 1`
do
    yes | # --------------------------------
    mdadm                                  \
        --create                           \
        --quiet                            \
        --raid-devices=2                   \
        --level=mirror                     \
        --name ${MD_NAME}_$i               \
        /dev/md/${MD_NAME}_$i              \
        /dev/loop{$(( $i*2 )),$(($i*2+1))}
done

exit 0
