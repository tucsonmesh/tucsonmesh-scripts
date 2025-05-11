#!/usr/bin/env bash

# Do you have a node that's very flakey? It's because of a silly configuration change you made?
# You now need to wait for it to come up and then quickly run a command to fix your silly mistake?
# Use this script! Put whatever command you need to run at the bottom and wish for the best.

server=10.69.0.62

while ! nc -z $server 22 >/dev/null; do
  echo "Waiting for connection...";
  sleep 10
done

echo "Connection should be available!"

sshpass -f ./omni-password-file ssh admin@$server "/interface wireless set wlan4 disabled=\"no\""
