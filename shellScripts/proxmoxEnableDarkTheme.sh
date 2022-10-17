#!/bin/bash

# Download and Enable Proxmox Dark Mode Theme
	# Ref: https://github.com/Weilbyte/PVEDiscordDark

# function
confirmPackageInstalled() { if [[ $(dpkg -l | grep -c $1) -gt 0 ]]; then return 0; else return 1; fi }

# Confirm Proxmox is installed
confirmPackageInstalled pve-manager
status=$?

if [[ $status -eq 0 ]]; then
	# Download and run PVE Discord Dark
	bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install
else
	echo "Error: Proxmox does not seem to be installed. Exiting."
	exit 1
fi