#!/bin/bash -e
#
# $Id: adblock.sh,v 1.1 2003/10/07 23:42:17 ktsaou Exp $
# A script that will fetch the IPs of popular add servers.
#  - Updated to run FireHOL on success
#
# To use this, just put in your cron jobs, like this:
#
#      0 * * * * /path/to/adblock.sh >/etc/firehol/adblock-ips
#
# and then in your firehol.conf:
#
#     source /etc/firehol/adblock-ips
#
# later in the config file you can use (for example)
#
#     client http accept dst not "${ADSERVERS_IPS}"
#
# or even:
#
#     blacklist full "${ADSERVERS_IPS}"
#
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/usr/sbin:/bin:/usr/bin
export PATH

printf "ADSERVERS_IPS=\""
printf "%q " `wget -q -O - "http://pgl.yoyo.org/adservers/iplist.php?ipformat=plain&showintro=0" | egrep -e "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\$"`
printf "\"\n"

firehol start