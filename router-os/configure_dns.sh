#!/usr/bin/env bash

# This script was used when updates were needed for all DNS servers on all active omnis
# 
# It configures both the upstream DNS settings (/ip dns) and the DNS servers handed out
# over DHCP via /ip dhcp-server

for nn in 53 54 55 56 57 58 61 62 63 64 65 67 68 71 72 73 75 76 77 79 80 81 82 83 84; do
  server=10.69.0.${nn}

  echo "Configuring Omni-${nn}"

  # Check we can reach it
  while ! nc -z $server 22 >/dev/null; do
    echo "Waiting for connection...";
    sleep 1
  done

  # Set the omni's internal DNS servers
  echo "Configuring the Omni-${nn}'s DNS servers"
  sshpass -f ./omni-password-file ssh admin@${server} '/ip dns set servers=1.1.1.1,1.0.0.1,10.10.10.10'

  # Set the DNS servers the omni hands out over DHCP
  # https://stackoverflow.com/a/23930212
  # Multiline string as a variable. Then flatten it so that RouterOS doesn't get mad
  read -r -d '' DNSCMD <<- EOM
  { 
    :local existingDNS [/ip dhcp-server network get [/ip dhcp-server network find where dns-server~"^10.10.10.10,.*"] value-name=dns-server]; 
    :local thisOmni [:pick \$existingDNS [:find \$existingDNS "," 0] [:len \$existingDNS]];
    :set thisOmni [:pick \$thisOmni 1 [:len \$thisOmni]];
    /ip dhcp-server network set [/ip dhcp-server network find where dns-server~"^10.10.10.10,.*"] dns-server=( "\$thisOmni" . ",1.1.1.1,1.0.0.1" );
  }
EOM

  # As mentioned, remove newlines so RouterOS doesn't get mad
  DNSCMD=${DNSCMD/$'\n'/}

  # Execute on the remote omni
  echo "Setting Omni-${nn}'s DHCP-supplied DNS servers"
  sshpass -f ./omni-password-file ssh admin@${server} ${DNSCMD}
done

