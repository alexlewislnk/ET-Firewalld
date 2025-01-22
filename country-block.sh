#!/bin/bash
#
# change the ISO field to include the two letter country codes for the countries you want to block
# see http://www.ipdeny.com/ipblocks/ for list of countries and their two-letter codes
# use lower case letters and separate with a space
#
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ISO="af al dz ao by bo ba bg bf cm cf cn cd ci hr cu et ht hk ir iq ke kp xk lb ly mk ml mc me mz mm na ni ng ph ru rs so za ss sd sy tz ua ve vn ye"

ZONEROOT="/usr/local/tmp"
DLROOT="http://www.ipdeny.com/ipblocks/data/aggregated"
geoTEMP="$ZONEROOT/geo-block.tmp"
geoBLOCK="$ZONEROOT/geo-block.txt"
mkdir -p $ZONEROOT
rm $geoTEMP $geoBLOCK
touch $geoTEMP
for c  in $ISO
do
        tDB=$ZONEROOT/$c.zone
        wget -O $tDB $DLROOT/$c-aggregated.zone
        egrep -v "^#|^$" $tDB >> $geoTEMP
done
sort -V $geoTEMP | /usr/local/bin/ip-aggregate.pl > $geoBLOCK
ipset create geo-block hash:net -exist
ipset flush geo-block
logger "Geoblock Update: Geo list flushed"
x=0
for ipblock in `cat $geoBLOCK`
do
        ipset -A geo-block $ipblock
        (( x++ ))
done
logger "Geoblock Update: $x subnets added to Geo List"
exit 0
