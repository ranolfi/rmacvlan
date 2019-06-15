## rmacvlan - macvlan bridge for easy networking with virtual machines

When creating a virtual machine in the Red Hat's [Virtual Machine Manager](https://virt-manager.org/), upon choosing a host device `macvtap` network interface you will be warned:

> In most configurations, macvtap does not work for host to guest network communication.

This script, provided as a `systemd` service unit, will setup a macvlan interface in the host that can be used in virtual machines to make that possible.

To use it, edit the `rmacvlan.sh` script - set up the hardware interface name, and (optionally) change the macvlan name in the `# [Configuration]` section; then, simply enable and start `rmacvlan.service`:

    # systemctl enable rmacvlan --now

<br>

### Notes:

1. This is a one-shot service; removing the macvlan routing can only be done manually at this moment:

       # ip link delete rmacvlan
       # ip route flush dev enp10s0

<br>

Based on work by Evert Mouw, 2013 - [Enabling host-guest networking with KVM, Macvlan and Macvtap](https://www.furorteutonicus.eu/2013/08/04/enabling-host-guest-networking-with-kvm-macvlan-and-macvtap/).


