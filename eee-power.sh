#!/bin/sh
#FILE: /etc/init.d/eee-overclock.sh
# change FSB clock of the Asus EEE using the 'eee' module
# setup the processor to run at 675Mhz in normal load and 900Mhz in heavy load
# using p4-clockmod and cpufreq-ondemand (overclocking in steps to prevent freezes)

# this script needs to be called at start time and when suspending
case "$1" in
  performance)
     # start overclocker module, overclock in too steps
     modprobe asus_eee
     echo 85 24 1 > /proc/eee/fsb
     sleep 1
     echo 100 24 1 > /proc/eee/fsb
     # start frequency scaling modules
     modprobe p4-clockmod
     modprobe cpufreq-ondemand
     echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
     # set frequency to minimize fan rotation if no cpu is needed
     echo 675000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
     ;;
  stop)
     # gradually restore frequency
     echo 85 24 1 > /proc/eee/fsb
     sleep 1
     echo 70 24 1 > /proc/eee/fsb
     # remove frequency management modules
     modprobe -r asus_eee
     echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
     modprobe -r p4-clockmod
     ;;
  powersave)
    modprobe asus_eee

    echo 55 24 1 > /proc/eee/fsb
    sleep 1
    echo 30 24 1 > /proc/eee/fsb

    modprobe p4-clockmod
    modprobe cpufreq-powersave
    echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    # set frequency to minimize fan rotation if no cpu is needed
    echo 112500 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

    echo -n 2 > /sys/class/backlight/eeepc/brightness
    echo -n 5 > /proc/sys/vm/laptop_mode

    echo -n 1 > /proc/sys/kernel/watchdog
    echo -n 1500 > /proc/sys/vm/dirty_writeback_centisecs
    echo 10 > /sys/module/snd_hda_intel/parameters/power_save

    # PCI device
    for i in /sys/bus/pci/devices/*/power/control ; do
      echo -n auto > ${i}
    done

    # USB devices
    for i in /sys/bus/usb/devices/*/power/control ; do
      echo -n auto > ${i}
    done

    for i in /sys/bus/usb/devices/*/power/autosuspend ; do 
      echo -n 1 > ${i}
    done

    # LAN port
    #ethtool -s p2p1 wol d

    echo 0 > /proc/sys/kernel/nmi_watchdog
  ;;
esac

