#!/bin/sh


clear >"$(tty)"

cat <<EOF

████████╗██╗   ██╗ ██████╗███████╗ ██████╗ ███╗   ██╗    ███╗   ███╗███████╗███████╗██╗  ██╗
╚══██╔══╝██║   ██║██╔════╝██╔════╝██╔═══██╗████╗  ██║    ████╗ ████║██╔════╝██╔════╝██║  ██║
   ██║   ██║   ██║██║     ███████╗██║   ██║██╔██╗ ██║    ██╔████╔██║█████╗  ███████╗███████║
   ██║   ██║   ██║██║     ╚════██║██║   ██║██║╚██╗██║    ██║╚██╔╝██║██╔══╝  ╚════██║██╔══██║
   ██║   ╚██████╔╝╚██████╗███████║╚██████╔╝██║ ╚████║    ██║ ╚═╝ ██║███████╗███████║██║  ██║
   ╚═╝    ╚═════╝  ╚═════╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝    ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝

 ██████╗ ███╗   ███╗███╗   ██╗██╗████████╗██╗██╗  ██╗     ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
██╔═══██╗████╗ ████║████╗  ██║██║╚══██╔══╝██║██║ ██╔╝    ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
██║   ██║██╔████╔██║██╔██╗ ██║██║   ██║   ██║█████╔╝     ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
██║   ██║██║╚██╔╝██║██║╚██╗██║██║   ██║   ██║██╔═██╗     ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║   ██║   ██║██║  ██╗    ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
 ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝

EOF

print_usage() {
cat <<EOF

  Usage: ${0} firmware_path configuration_path

  A simple program for configuring an Omnitik 5 AC PoE router from factory settings for use in Tucson Mesh.

  firmware_path: path to the firmware file to be flashed.
  configuration_path: path to the configuration file to be flashed.

EOF
}

if [ $# -lt 2 ]; then
  echo "  ERROR: missing arguments" >&2
  print_usage
  exit 1
fi

if [ $# -gt 2 ]; then
  echo "  WARNING: extra arguments provided. Ignoring them..." >&2
fi

firmware_path="${1}"
config_path="${2}"

if [ ! -f "${firmware_path}" ]; then
  echo "  ERROR: unable to locate firmware file: ${firmware_path}"
  exit 1
fi

if [ ! -f "${config_path}" ]; then
  echo "  ERROR: unable to locate configuration file: ${config_path}"
  exit 1
fi

config_name="${config_path##*/}"

echo "  Before we can configure the Omnitik, we need to make sure it's powered on and we've switched to the management WiFi network it creates."
echo "  Alternatively, you can also connect to the Omnitik over Ethernet. Either works."
echo ""
echo "  Once you're done with this, press enter to continue..."
read -r

echo "  Checking if the Omnitik is reachable..."
if ! ping -c 1 192.168.88.1 -W 2; then
  echo "  ERROR: I can't ping the Omnitik. It might not be reachable. If you've just plugged it in, it might take time to boot up." >&2
  echo "  Otherwise, please check that you're connected to the Omnitik's network and try again" >&2
  exit 1
fi

echo "  Looks like the Omnitik is reachable. Proceeding with configuration"
echo ""

ssh_opts="-o HostKeyAlgorithms=+ssh-rsa -o UserKnownHostsFile=/dev/null"

echo "  Copying firmware file to the Omnitik"

if ! scp ${ssh_opts} "${firmware_path}" admin@192.168.88.1:/; then
  echo "  ERROR: unable to copy firmware (${firmware_path}) to Omnitik!"
  exit 1
fi

echo "  Copying configuration file to the Omnitik"
echo ""

if ! scp ${ssh_opts} "${config_path}" admin@192.168.88.1:/flash/"${config_name}"; then
  echo "  ERROR: unable to copy configuration file (${config_path}) to Omnitik!"
  exit 1
fi

ssh_cmd="/system reset-configuration no-defaults=yes run-after-reset=\"flash/${config_name}\""

echo "  Now, before we actually reset the Omnitik, please check that the SSH command we'll execute looks correct"
echo ""
echo "${ssh_cmd}"
echo ""
echo -n "  Seem legit? (Y/N): "
read -r LEGIT

if [ "${LEGIT}" = "Y" ] || [ "${LEGIT}" = "y" ] || [ "${LEGIT}" = "YES" ] || [ "${LEGIT}" = "yes" ]; then
  echo "  Resetting the Omnitik, flashing the new firmware, and updating the configuration..."
  ssh ${ssh_opts} admin@192.168.88.1 "${ssh_cmd}"
  echo "  The command ran successfully (probably, tbh we don't really know). Now to just wait for the Omnitik to reboot, flash the firmware, apply the new configuration, and sing its little tune"
else
  echo "  Okay, I won't do anything then :("
fi
