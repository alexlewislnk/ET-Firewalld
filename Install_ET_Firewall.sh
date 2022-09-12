#!/bin/bash
#
# Install and configure Firewalld with an IP blocklist for specific countries
# and an IP blocklist for IPs and IP netblocks that are known threats.
# The IP Sets utility is used for faster table updates to the blocklist and
# faster matching in the firewall. 
#
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
LOG=/root/Install_ET_Firewall.log
RED="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
CYAN="$(tput setaf 6)"
NORMAL="$(tput sgr0)"

function DisplayInfo { 
	printf "${CYAN}$INFO${NORMAL}\\n"
	printf "\\n$INFO\\n" >>$LOG
}

INFO="Firewalld setup started at $(date)" ; DisplayInfo

INFO="Installing firewalld" ; DisplayInfo
export DEBIAN_FRONTEND=noninteractive
apt update >>$LOG 2>&1
apt -y purge ufw >>$LOG 2>&1
apt -y install firewalld ipset libnet-ip-perl >>$LOG 2>&1

INFO="Make sure ssh (tcp/22) is allowed" ; DisplayInfo
firewall-cmd --zone=public --add-service=ssh --permanent >>$LOG 2>&1
firewall-cmd --reload >>$LOG 2>&1

INFO="Download scripts to load Emerging Threats and Geo Blocklists" ; DisplayInfo
wget -O /usr/local/bin/ip-aggregate.pl https://raw.githubusercontent.com/alexlewislnk/ET-Firewalld/main/ip-aggregate.pl >>$LOG 2>&1
wget -O /usr/local/bin/emerging-threats-update.sh https://raw.githubusercontent.com/alexlewislnk/ET-Firewalld/main/emerging-threats-update.sh >>$LOG 2>&1
wget -O /usr/local/bin/country-block.sh https://raw.githubusercontent.com/alexlewislnk/ET-Firewalld/main/country-block.sh >>$LOG 2>&1
wget -O /usr/local/bin/ipset-backup.sh https://raw.githubusercontent.com/alexlewislnk/ET-Firewalld/main/ipset-backup.sh >>$LOG 2>&1
wget -O /usr/local/bin/ipset-restore.sh https://raw.githubusercontent.com/alexlewislnk/ET-Firewalld/main/ipset-restore.sh >>$LOG 2>&1
chmod +rx /usr/local/bin/*.pl /usr/local/bin/*.sh >>$LOG 2>&1

INFO="Create ipset lists and add blocklists to firewalld" ; DisplayInfo
firewall-cmd --permanent --new-ipset=threat-ip --type=hash:ip >>$LOG 2>&1
firewall-cmd --permanent --new-ipset=threat-net --type=hash:net >>$LOG 2>&1
firewall-cmd --permanent --new-ipset=geo-block --type=hash:net >>$LOG 2>&1
firewall-cmd --permanent --add-rich-rule='rule source ipset=threat-ip log prefix="THREAT BLOCK:" drop' >>$LOG 2>&1
firewall-cmd --permanent --add-rich-rule='rule source ipset=threat-net log prefix="THREAT BLOCK:" drop' >>$LOG 2>&1
firewall-cmd --permanent --add-rich-rule='rule source ipset=geo-block log prefix="GEO BLOCK:" drop' >>$LOG 2>&1
firewall-cmd --reload >>$LOG 2>&1

INFO="Run initial download of the blocklists" ; DisplayInfo
/usr/local/bin/emerging-threats-update.sh >>$LOG 2>&1
/usr/local/bin/country-block.sh >>$LOG 2>&1
/usr/local/bin/ipset-backup.sh >>$LOG 2>&1

INFO="Setup crontab to regularly update and backup the blocklists and restore on reboot" ; DisplayInfo
(crontab -l 2>> $LOG ; echo "@hourly /usr/local/bin/emerging-threats-update.sh" )| crontab - >>$LOG 2>&1
(crontab -l 2>> $LOG ; echo "@daily /usr/local/bin/country-block.sh" )| crontab - >>$LOG 2>&1
(crontab -l 2>> $LOG ; echo "15 * * * * /usr/local/bin/ipset-backup.sh" )| crontab - >>$LOG 2>&1
(crontab -l 2>> $LOG ; echo "@reboot sleep 60 ; /usr/local/bin/ipset-restore.sh" )| crontab - >>$LOG 2>&1

INFO="Firewalld setup completed at $(date)" ; DisplayInfo
INFO="${YELLOW}Check log file ${RED}$LOG${YELLOW} for any errors" ; DisplayInfo
# End
