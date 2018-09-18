#!/bin/bash

##########################################################################
#                                                                        #
# NordVPN Quick VPN Script                                               #
#                                                                        #
# This script makes a quick call to NordVPN's Server Recommendation API  #
# and grabs the recommended server to connect via command line using     #
# OpenVPN. It is the functionality as on the NordVPN webpage.            #
#                                                                        #
#                                                                        #
# Michael Moro                                                           #
# Email:    michael.moro@bonaventuredigital.com                          #
# Twitter:  @michael_moro                                                #
# LinkedIn: http://www.linkedin.com/in/mikemoro                          #
#                                                                        #
##########################################################################

VERSION="0.2"

NORDJSONTMP="/tmp/nordservers.json.tmp"

curl -o $NORDJSONTMP -s 'https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations'

if [ ! -f $NORDJSONTMP ]; then
	echo "[ERROR]: Unable to download recommended servers list from NordVPN."
	exit 1
fi

NORDHOSTNAME=`python -c "import sys, json; print json.load(open('$NORDJSONTMP'))[0]['hostname']"`
NORDHOST=`python -c "import sys, json; print json.load(open('$NORDJSONTMP'))[0]['name']"`
OVPNFILE="/etc/openvpn/$NORDHOSTNAME.udp1194.ovpn"

if [ -z $NORDHOSTNAME ]; then
	echo "[ERROR]: Unable to parse response from NordVPN."
	exit 1
fi

echo
echo "[Recommended NordVPN Server]: $NORDHOST ($NORDHOSTNAME)"
echo

if [ ! -f $OVPNFILE ]; then
	curl -s -o $OVPNFILE https://downloads.nordcdn.com/configs/files/ovpn_legacy/servers/$NORDHOSTNAME.udp1194.ovpn
fi

grep "credentials.txt" $OVPNFILE > /dev/null
MOD_OVPN=$?

if [ $MOD_OVPN == 1 ]; then
	perl -p -i -e 's/auth-user-pass/auth-user-pass\ credentials\.txt/' $OVPNFILE
fi

ln -sf /etc/openvpn/$NORDHOSTNAME.udp1194.ovpn /etc/openvpn/default.conf


