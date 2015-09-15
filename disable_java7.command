#! /bin/sh

# Shell script to disable Java 7 and re-enable Java SE 6
# Author: Romig, Adam (RET-DAY)
# Last Modified: 03/19/2013

# Get who is logged in
me="$(whoami)"

echo "Logged in as: $me"

if
	# Check to see if it's the local admin account or user's ma- account
	[ $me = "ret-clientadmin" ] || [ ${me:0:3} = "ma-" ]
then
	echo "... Creating directory in which to place Java 7 plug-in"
	sudo mkdir -p /Library/Internet\ Plug-Ins/disabled

	# Check to see if the plugin link is already there and remove it if it exists
	cd /Library/Internet\ Plug-Ins/disabled
	if
		[ -f JavaAppletPlugin.plugin ]
	then
		sudo rm JavaAppletPlugin.plugin
	fi

	echo "... Moving current Java 7 plug-in into disabled directory"
	sudo mv /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin /Library/Internet\ Plug-Ins/disabled

	echo "... Creating new symbolic links from Java SE 6 to Java Applet references"
	sudo ln -sf /System/Library/Java/Support/Deploy.bundle/Contents/Resources/JavaPlugin2_NPAPI.plugin /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin

	sudo ln -sf /System/Library/Frameworks/JavaVM.framework/Commands/javaws /usr/bin/javaws

	echo "... done!"
	exit 0
else
	echo "... This script needs to be run as a local administrator account."
	exit 1
fi
