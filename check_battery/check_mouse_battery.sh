#!/bin/sh
PATH=/usr/local/bin:/usr/local/sbin:~/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Script that checks the battery level of a connected mouse and displays a notification if it is below a threshold (default 15%). Can set threshold as a parameter. ex: ./check_mouse_battery.sh 10

MOUSENAME=`ioreg -c AppleDeviceManagementHIDEventService -r -l | grep -i mouse | cut -d = -f2 | cut -d \" -f2`

MOUSEBATTERY=`ioreg -c AppleDeviceManagementHIDEventService -r -l | grep -i mouse -A 20  | grep BatteryPercent | cut -d = -f2 | cut -d ' ' -f2`

COMPARE=${1:-15}

if [ -z "$MOUSEBATTERY" ]; then
    echo 'No Mouse Found.'
    exit 0
fi

if (( MOUSEBATTERY < COMPARE )); then
    osascript -e "display notification \"Battery Level at ${MOUSEBATTERY}%.\" with title \"Battery Low\" subtitle \"${MOUSENAME}\""
fi