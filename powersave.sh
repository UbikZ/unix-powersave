#!/bin/bash

### BEGIN INIT INFO
# Provides:          powersave
# Required-Start:    $all
# Required-Stop:     $all
# Should-Start:     
# Should-Stop:      
# X-Start-Before:   
# X-Interactive:     false
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6 
# Short-Description: Powersave script  
# Description: This scipt improve power managment.                          
### END INIT INFO

############################
#Script d'économie d'énergie
############################
#
#Configuration dans "/etc/acpi/events/battery" :
#event=ac_adapter
#action=/home/powersave.sh

if grep -q 1 /sys/class/power_supply/ADP1/online
then
	echo "Passage en alimentation secteur"

	iwconfig wlan0 power off
	rfkill unblock bluetooth
	echo "527" > /sys/class/backlight/intel_backlight/brightness
	echo "1" > /proc/sys/kernel/nmi_watchdog;
	echo "" > /proc/sys/vm/dirty_writeback_centisecs;
	echo "" > /sys/module/snd_hda_intel/parameters/power_save;

	for config_file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
		echo "performance >" $config_file
		echo "performance" > $config_file
	done

	for config_file in /sys/bus/usb/devices/*/power/control; do
		echo "on >" $config_file;
		echo "on" > $config_file;
	done 

	for config_file in /sys/bus/pci/devices/0000*/power/control; do
		echo "on >" $config_file;
		echo "on" > $config_file;
	done

	for config_file in /sys/class/scsi_host/host*/link_power_management_policy; do
 		echo " >" $config_file
 		echo "" >$config_file
	done

else

	echo "Passage en alimentation batterie"
	
	iwconfig wlan0 power on
	iwconfig wlan0 power timeout 1000ms
	rfkill block bluetooth
	echo "26" > /sys/class/backlight/intel_backlight/brightness
	echo "0" > /proc/sys/kernel/nmi_watchdog;
	echo "1500" > /proc/sys/vm/dirty_writeback_centisecs;
	echo "5" > /proc/sys/vm/laptop_mode
	echo "Y" > /sys/module/snd_hda_intel/parameters/power_save_controller 
	echo "1" > /sys/module/snd_hda_intel/parameters/power_save

	for config_file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
		echo "powersave >" $config_file
		echo "powersave" >$config_file
	done

	for config_file in /sys/bus/usb/devices/*/power/autosuspend; do
		echo "1 >" $config_file;
		echo "1" > $config_file;
	done 

	for config_file in /sys/bus/usb/devices/*/power/control; do
		echo "auto >" $config_file;
		echo "auto" > $config_file;
	done 

	for config_file in /sys/bus/pci/devices/0000*/power/control; do
		echo "auto >" $config_file;
		echo "auto" > $config_file;
	done

	for config_file in /sys/class/scsi_host/host*/link_power_management_policy; do
		echo "min_power >" $config_file                                            
		echo "min_power" > $config_file                                            
	done

	xset +dpms
	xset dpms 0 0 300		

fi

mount -o remount,noatime /
hdparm -B 128 -S 12 /dev/sda

