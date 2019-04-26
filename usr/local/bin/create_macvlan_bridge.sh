#!/bin/sh

# Evert Mouw, 2013
# Modified by Marc Ranolfi, 2017-07-24

# ------------
# wait for network availability
# ------------
TESTHOST=kernel.org
while ! ping -q -c 1 $TESTHOST > /dev/null
do
    echo "$0: Cannot ping $TESTHOST, waiting another 5 secs..."
    sleep 5
done

# ------------
# network config
# ------------
HWLINK=enp10s0
MACVLN=macvlan0

IP=192.168.1.3/24
NETWORK=192.168.1.0/24
GATEWAY=192.168.1.1

# ------------
# setting up $MACVLN interface
# ------------
ip link add link $HWLINK $MACVLN type macvlan mode bridge
ip address add $IP dev $MACVLN
ip link set dev $MACVLN up

# ------------
# routing table
# ------------
# empty routes
ip route flush dev $HWLINK
ip route flush dev $MACVLN

# add routes
ip route add $NETWORK dev $MACVLN metric 0

# add the default gateway
ip route add default via $GATEWAY