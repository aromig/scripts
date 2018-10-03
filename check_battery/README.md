# Mouse & Keyboard Battery Check Scripts

## Purpose

For some reason, macOS has a low mouse/keyboard battery threshold set at 2%. I needed a bit more warning than that.

These scripts check the battery level of a connected mouse and keyboard (separate scripts) and displays a notification if it is below a threshold (default 15%). The threshold can be set threshold as a parameter. Example: `./check_mouse_battery.sh 10` to check against 10% battery.

![Battery](check_mouse_battery_notification.png)

## Contents

### Bash Scripts

* check_mouse_battery.sh
* check_kb_battery.sh

### Property List Files

* com.penguingeek.checkmousebattery.plist
* com.penguingeek.checkkeyboardbattery.plist

These are configured to run at the top of every even hour (02:00, 04:00, 06:00, 08:00, 10:00, etc).

## Installation

1. Copy the script (.sh) files to somewhere convenient (ex: your home folder).
2. Copy the property list (.plist) files to your `~/Library/LaunchAgents/` folder.
3. Edit the plist files and change the path to the scripts.

   ```xml
   <array>
       <string>sh</string>
       <string>-c</string>
       <string>/Users/romigar/check_kb_battery.sh</string> <!-- Change theis path! -->
   </array>
    ```

4. Load the service by running:
   * `launchctl load -w ~/Library/LaunchAgents/com.penguingeek.check_mouse_battery.plist`
   * `launchctl load -w ~/Library/LaunchAgents/com.penguingeek.check_kb_battery.plist`