#!/usr/bin/env bash

IPADDRS="192.168.10.100 192.168.20.100 192.168.30.100 192.168.10.2 192.168.20.2 192.168.20.3 192.168.30.2 192.168.50.10 192.168.50.20"
HOSTS=$(vagrant status | grep running | awk '{print $1}')

for host in $HOSTS; do
  echo "$host"
  echo "========================"
  echo "ip route list:"
  vagrant ssh "$host" -c "ip route list"
  if [[ "$host" =~ ^r ]]; then
    echo "show ip bgp:"
    vagrant ssh "$host" -c "sudo vtysh -c 'show ip bgp' && sudo vtysh -c 'show ip bgp summary'"
  fi
  for ipaddr in $IPADDRS; do
    result=$(vagrant ssh "$host" -- ping -c1 "$ipaddr" | awk -F, '/packet loss/ {print $3}')
    echo "$host -> $ipaddr: $result"
  done
  echo
done
