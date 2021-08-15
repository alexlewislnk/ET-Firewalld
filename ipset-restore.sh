#!/bin/bash
# Run from cron @reboot to restore most recent ipset lists
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
IPSETBACKUP=/usr/local/tmp/ipset.backup
ipset restore -exist -file $IPSETBACKUP
