# ET-Firewalld
Scripts for Firewalld with an IP blocklist for specific countries and an IP blocklist for IPs and IP netblocks that are known threats. This uses the IP Sets utility for faster table updates to the blocklist and faster matching in the firewall.

## Steps to install
(Login as root)

Download Install Script
```
wget -O /tmp/Install_ET_Firewall.sh https://raw.githubusercontent.com/alexlewislnk/ET-Firewalld/main/Install_ET_Firewall.sh
chmod +rx /tmp/Install_ET_Firewall.sh
```

Execute the script
```
/tmp/Install_ET_Firewall.sh
```

Examine the script logfile (/root/Install_ET_Firewall.log) for any errors.
