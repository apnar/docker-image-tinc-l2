#!/bin/sh

# convert eth0 to bridge
GW=$(/sbin/ip route | awk '/default/ { print $3 }')
brctl addbr tinc-bridge
ifconfig tinc-bridge `ifconfig eth0 | grep netmask | sed -e 's/.*inet//' -e 's/broad.*//'`
ifconfig eth0 down
ip address flush dev eth0
brctl addif tinc-bridge eth0
ifconfig eth0 up
route add default gw $GW

exec /usr/sbin/tinc start -D -U nobody

