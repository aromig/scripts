#!/bin/sh
PATH=/usr/local/bin:/usr/local/sbin:~/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Script that checks the battery level of a connected Magic Keyboard and displays a notification if it is below a threshold (default 15%). Can set threshold as a parameter. ex: ./check_kb_battery.sh 10

KBNAME=`ioreg -c AppleDeviceManagementHIDEventService -r -l | grep -i 'Magic Keyboard' | cut -d = -f2 | cut -d \" -f2`

KBBATTERY=`ioreg -c AppleDeviceManagementHIDEventService -r -l | grep -i keyboard -A 20  | grep BatteryPercent | cut -d = -f2 | cut -d ' ' -f2`

COMPARE=${1:-15}

if [ -z "$KBBATTERY" ]; then
    echo 'No Mouse Found.'
    exit 0
fi

if (( KBBATTERY < COMPARE )); then
    osascript -e "display notification \"Battery Level at ${KBBATTERY}%.\" with title \"Battery Low\" subtitle \"${KBNAME}\""
fi