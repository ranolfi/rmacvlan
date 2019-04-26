#!/bin/sh
#
# rmacvlan - macvlan bridge for easy networking with virtual machines
#
# Marc Ranolfi, 2018-02-18 <mranolfi@gmail.com>
#
# Based on work by Evert Mouw, 2013 <https://www.furorteutonicus.eu/2013/08/04/enabling-host-guest-networking-with-kvm-macvlan-and-macvtap/>
#

# Configuration
HWLINK=enp10s0
MACVLAN=rmacvlan
TESTHOST=kernel.org
# #

# wait for network availability
while ! ping -q -c 1 $TESTHOST > /dev/null
do
	echo "$0: Cannot ping $TESTHOST, waiting another 5 secs..."
	sleep 5
done

# get network config
IP=$(ip address show dev $HWLINK | grep "inet " | awk '{print $2}')
NETWORK=$(ip -o route | grep $HWLINK | grep -v default | awk '{print $1}')
GATEWAY=$(ip -o route | grep default | awk '{print $3}')

# set up $MACVLAN interface
ip link add link $HWLINK $MACVLAN type macvlan mode bridge
ip address add $IP dev $MACVLAN
ip link set dev $MACVLAN up

# routing table
## empty routes
ip route flush dev $HWLINK
ip route flush dev $MACVLAN

## add routes
ip route add $NETWORK dev $MACVLAN metric 0

## add the default gateway
ip route add default via $GATEWAY

