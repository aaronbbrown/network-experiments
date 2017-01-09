#!/usr/bin/env bash

source "/usr/local/etc/ips"

host="$(hostname -s)"

echo "ip route list:"
ip route list

if [[ "$host" =~ ^r ]]; then
  echo "BGP"
  vtysh -c 'show ip bgp'
  vtysh -c 'show ip bgp summary'
fi

for ipaddr in $IPADDRS; do
  result="$(ping -c1 "$ipaddr" | awk -F, '/packet loss/ {print $3}')"
  echo "$host -> $ipaddr: $result"
done

