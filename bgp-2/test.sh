#!/usr/bin/env bash

HOSTS=$(vagrant status | grep running | awk '{print $1}')

for host in $HOSTS; do
  echo "$host"
  echo "========================"
  vagrant ssh $host -c "sudo /vagrant/debug.sh"
done
