#!/bin/bash
#
# Install and configure Firewalld with an IP blocklist for specific countries
# and an IP blocklist for IPs and IP netblocks that are known threats.
# The IP Sets utility is used for faster table updates to the blocklist and
# faster matching in the firewall. 
#
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "Installing firewalld"
apt -y install firewalld ipset libnet-ip-perl

echo "Make sure ssh (tcp/22) is allowed"
firewall-cmd --zone=public --add-service=ssh --permanent
firewall-cmd --reload

echo "Download scripts to load Emerging Threats and Geo Blocklists"
wget -O /usr/local/bin/ip-aggregate.pl https://raw.githubusercontent.com/alexlewislnk/ET-Firewalld/main/ip-aggregate.pl
wget -O /usr/local/bin/emerging-threats-update.sh https://raw.githubusercontent.com/alexlewislnk/ET-Firewalld/main/emerging-threats-update.sh
wget -O /usr/local/bin/country-block.sh https://raw.githubusercontent.com/alexlewislnk/ET-Firewalld/main/country-block.sh
wget -O /usr/local/bin/ipset-backup.sh https://raw.githubusercontent.com/alexlewislnk/ET-Firewalld/main/ipset-backup.sh
wget -O /usr/local/bin/ipset-restore.sh https://raw.githubusercontent.com/alexlewislnk/ET-Firewalld/main/ipset-restore.sh
chmod +rx /usr/local/bin/ip-aggregate.pl /usr/local/bin/emerging-threats-update.sh /usr/local/bin/country-block.sh /usr/local/bin/ipset-backup.sh /usr/local/bin/ipset-restore.sh

echo "Create ipset lists and add blocklists to firewalld"
firewall-cmd --permanent --new-ipset=threat-ip --type=hash:ip
firewall-cmd --permanent --new-ipset=threat-net --type=hash:net
firewall-cmd --permanent --new-ipset=geo-block --type=hash:net
firewall-cmd --permanent --add-rich-rule='rule source ipset=threat-ip log prefix="THREAT BLOCK:" drop'
firewall-cmd --permanent --add-rich-rule='rule source ipset=threat-net log prefix="THREAT BLOCK:" drop'
firewall-cmd --permanent --add-rich-rule='rule source ipset=geo-block log prefix="GEO BLOCK:" drop'
firewall-cmd --reload

echo "Run initial download of the blocklists"
/usr/local/bin/emerging-threats-update.sh > /dev/null 2>&1
/usr/local/bin/country-block.sh > /dev/null 2>&1
/usr/local/bin/ipset-backup.sh

echo "Setup crontab to regular update and backup the blocklists and restore on reboot"
(crontab -l ; echo "@hourly /usr/local/bin/emerging-threats-update.sh" )| crontab -
(crontab -l ; echo "@daily /usr/local/bin/country-block.sh" )| crontab -
(crontab -l ; echo "15 * * * * /usr/local/bin/ipset-backup.sh" )| crontab -
(crontab -l ; echo "@reboot sleep 60 ; /usr/local/bin/ipset-restore.sh" )| crontab -

# End
