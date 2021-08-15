#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
BLOCKfile=/usr/local/tmp/IP-Blocklist-clean.txt
mkdir -p /usr/local/tmp
rm -rf $BLOCKfile
wget -O $BLOCKfile https://www.neblink.net/blocklist/IP-Blocklist-clean.txt;type=a
ipset create threat-ip hash:ip -exist
ipset create threat-net hash:net -exist
ipset flush  threat-ip
logger "Threat Update: threat-ip list flushed"
ipset flush  threat-net
logger "Threat Update: threat-net list flushed"
x=0
y=0
for ipblock in `cat $BLOCKfile`
do
        if [[ "$ipblock" =~ "/" ]] ; then
                ipset -A threat-net $ipblock
                (( x++ ))
        else
                ipset -A threat-ip  $ipblock
                (( y++ ))
        fi
done
logger "Threat Update: $x IPs added to threat-ip list"
logger "Threat Update: $y Subnets added to threat-net list"
exit 0
