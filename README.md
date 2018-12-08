# Meraki WAN Emulator

This script will configure a Raspberry Pi as a WAN emulator, running a Meraki themed web interface for configuration.

This script assumes the following:
1. You will be using eth0 and eth1 as the bridged interfaces for the WAN Emulator. You will need a USB Ethernet Adapter compatible with the Raspberry Pi
2. You will be using wlan0 for access to the web interface, and that wlan0 is already configured.
3. The Raspberry Pi has apt installed

To install, simply run this command:

`wget https://raw.githubusercontent.com/nathanwiens/merakiwanemulator/master/meraki_wan_emulator_install.sh && chmod a+x meraki_wan_emulator_install.sh && sudo ./meraki_wan_emulator_install.sh`

You can either automatically cycle the WAN Emulation automatically (via cron job), or set it manually via the web interface.
Thresholds for the cron job can be modified by editing the scripts in /var/www/html/cron after installation.

Here's what the interface looks like:
![alt text](https://raw.githubusercontent.com/nathanwiens/merakiwanemulator/master/wanemulator.png)
