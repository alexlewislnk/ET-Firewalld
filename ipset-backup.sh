#!/bin/bash
# Run from cron regularly on so ipset lists can be restored afer a reboot
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
IPSETBACKUP=/usr/local/tmp/ipset.backup
ipset save -file $IPSETBACKUP
