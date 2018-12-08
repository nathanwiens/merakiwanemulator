#!/bin/bash
###
### Created by Nathan Wiens: https://github.com/nathanwiens and Shiyue Cheng: https://github.com/shiyuechengineer
### December 7, 2018
###

LOGFILE="/home/pi/sdwanlog.txt"

#Check for root
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit 1
fi

#Introduction
echo ""
echo "THIS SCRIPT ASSUMES YOU WILL USE WLAN0 FOR MANAGEMENT AND THAT WLAN0 IS ALREADY CONFIGURED"
echo "ETH0/ETH1 MANAGEMENT ACCESS TO THIS DEVICE WILL NOT BE POSSIBLE AFTER INSTALLATION"
echo ""
read -n 1 -s -r -p "Press any key to continue..."

#Install TC for WAN Emulation
echo ""
echo "INSTALLING TC FOR WAN EMULATION..."
echo ""
apt-get update
apt-get install iproute2 -y

#Install HTTP server
echo ""
echo "INSTALLING HTTP SERVER..."
echo ""
apt-get install lighttpd -y

#Adding logging to lighttpd
echo ""
echo "ADDING LOGGING TO HTTP SERVER..."
echo ""
grep -q -F "accesslog.filename = $LOGFILE" /etc/lighttpd/lighttpd.conf || echo "accesslog.filename = $LOGFILE" >> /etc/lighttpd/lighttpd.conf

#Install web files
echo ""
echo "INSTALLING WEB FILES..."
echo ""
wget https://github.com/nathanwiens/merakiwanemulator/blob/master/meraki_wan_emulator_files.tar.gz?raw=true
FILE="./meraki_wan_emulator_files.zip"
if [ -f $FILE ]; then
	tar -zxvf $FILE -C /var/www/
	touch $LOGFILE
	chmod 777 $LOGFILE
else
	echo "File $FILE does not exist."
	echo "Check the GitHub repository link and try again."
	echo "Exiting..."
	exit 1
fi;

#Configure Bridge interface
echo ""
echo "RECONFIGURING NETWORK INTERFACES"
echo ""
mv /var/www/html/interfaces /etc/network/

#Restart HTTP Server
echo ""
echo "RESTARTING HTTP SERVER..."
echo ""
/etc/init.d/lighttpd restart

#Install cron script for automatic adjustments
echo ""
echo "AUTOMATIC PERFORMANCE ADJUSTMENTS"
echo ""
while true; do
    read -p "Would you like automatic performance adjustments? " yn
    
	if  [ "$yn" == "Y" ] || [ "$yn" == "y" ] || [ "$yn" == "Yes" ] || [ "$yn" == "yes" ] || [ "$yn" == "YES" ]; then
	  while true; do
		  read -p "How long should each interval be (in minutes) (2-30)? " interval
		  if ! [[ "$interval" =~ ^[0-9]+$ ]]; then
            echo "Sorry integers only"
		  elif [ "$interval" == "" ]; then
			echo "Please specify an interval."
		  elif [ "$interval" -lt 1 ] || [ "$interval" -gt 30 ]; then
		    echo "Interval is $interval."
			echo "Please specify an interval between 2 and 30."
		  else
			echo "Interval is $interval."
			echo "Adding cron scripts."
			#Delete old cron jobs
			crontab -l | sed '/sdwanlog.txt/d' | crontab -
			#Add new cron jobs
			GOOD="$interval"
			BAD="$[interval/2]"
			crontab -l | { cat; echo "*/$GOOD * * * * bash /var/www/html/cron/perf-good.sh >> /home/pi/sdwanlog.txt"; } | crontab -
			crontab -l | { cat; echo "*/$BAD * * * * bash /var/www/html/cron/perf-bad.sh >> /home/pi/sdwanlog.txt"; } | crontab -
			break
		  fi
	  done
	  break
	elif [ "$yn" == "N" ] || [ "$yn" == "n" ] || [ "$yn" == "No" ] || [ "$yn" == "no" ] || [ "$yn" == "NO" ]; then
	  echo "Skipping..."
	  break
	else
	  echo "Please answer yes or no."
	fi
done

#Installation Complete
echo ""
echo "INSTALLATION COMPLETE."
echo "Please visit this IP address in a web browser to continue."
echo ""
