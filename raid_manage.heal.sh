#!/bin/sh

set -e

. $(dirname "$0")/raid_manage.config.sh 

for md in /dev/md/${MD_NAME}_*
do
    if
        mdadm --monitor --oneshot $md |
        grep --quiet DegradedArray
    then
        # There is, apparently, no straightforward way
        # to know exactly which device has failed.
        # So please taste fragility of regular expressions.

        md_realpath=$(basename $(readlink -f $md) )

        failed_dev=$(
            grep -F "$md_realpath" /proc/mdstat |
            grep -o '[a-z]\+[0-9]\+\[[0-9]\+\](F)' |
            grep -o '[a-z]\+[0-9]\+'
        )

        # Feels bitter?

        mdadm $md --remove $failed_dev
        mdadm $md --add $RESERVE

        # What if the reserve device is unavailable?
        # How to check if it's available?
        # I don't know of any simple way, sorry.

        logger "raid_manage: hot replaced <$failed_dev> in <$md> due to its apparent failure." 
        exit 0
    fi
done

exit 0
