#!/bin/sh
#
# rmacvlan - macvlan bridge for easy networking with virtual machines
#
# Marc Ranolfi, 2018-02-18 <mranolfi@gmail.com>
#
# Based on work by Evert Mouw, 2013 <https://www.furorteutonicus.eu/2013/08/04/enabling-host-guest-networking-with-kvm-macvlan-and-macvtap/>
#
# (Last updated on 2019-06-14)
#

# [Configuration]
HWLINK=enp10s0
MACVLAN=rmacvlan
TESTHOST=1.1.1.1 #TODO: use rping if that'd be an improvement
# uncomment and set target ip address for the macvlan - format: 192.168.0.3/24, although 192.168.0.3 also works
#IP=
# [/Configuration]


# wait for network availability
while ! ping -q -c 1 $TESTHOST > /dev/null
do
	echo "$0: Cannot ping $TESTHOST, waiting another 5 secs..."
	sleep 5
done

# get network config
if [ -z "$IP" ]
then
  HWIP=$(ip address show dev $HWLINK | awk '/inet / {print $2}')
  IP=$(echo "$HWIP" | awk -F '[./]' 'BEGIN {OFS = "."} {print $1, $2, $3, ++$4 "/" $5}') #[temp/note]: $5 = $NF; $4 = $(NF-1); ++$4 = ++$(NF-1).
# also: #$IP=$(awk -F '[./]' 'BEGIN {OFS = "."} {print $1, $2, $3, ++$4 "/" $5}' <<< $HWIP)
fi
NETWORK=$(ip -o route | awk -v hwlink="$HWLINK" '$0 ~ hwlink && ! /default/ {print $1}')
GATEWAY=$(ip -o route | awk '/default/ {print $3}')

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
