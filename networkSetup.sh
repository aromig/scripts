#! /bin/bash

# Script to automate several by-hand processes in setting up company MacBooks
# Author: Adam Romig
# Actual values redacted

if
	[ "$(id -u)" != "0" ]
then
	echo
	echo "ERROR: Must run script via sudo and with arguments."
	echo
	echo "Usage: sudo ./domainSetup.sh <Username>"
	exit 1
fi

if
	[ "$1" = "" ] || [ "$2" = "" ]
then
	echo
	echo "ERROR: Must run script with arguments."
	echo
	echo "Usage: sudo ./domainSetup.sh <ComputerName> <Username>"
	exit 1
fi

# Definitions
domain="domain"
groups="admin group 1,admin group 2"
computername=$(echo $1 | tr '[:lower:]' '[:upper:]')
fqdn=$computername.$domain

# Set computer name in System Preferences
echo
echo "=== Setting ComputerName and LocalHostName to \"$computername\""
scutil --set ComputerName $computername
scutil --set LocalHostName $computername

# Bind to domain
echo
echo "=== Binding \"$computername\" to \"$domain\" domain"
dsconfigad -a $computername -u $2 -ou "" -domain $domain

validateDomain=$(dsconfigad -show | grep "Active Directory Domain" | cut -c 36-)
if
	[ "$validateDomain" != $domain ]
then
	echo "ERROR: Active Directory Domain does not match domain definition."
	echo "Please make sure computer account was created in ADUC and re-try."
	exit 1
fi

# Set HostName
echo
echo "=== Setting HostName to \"$fqdn\""
scutil --set HostName $fqdn

# Gather existing Allowed admin groups
existingGroups=$(dsconfigad -show | grep "Allowed admin groups" | cut -c 36-)

if
	[ "$existingGroups" = "not set" ]
then
	existingGroups="domain admins,enterprise admins"
fi

# Add groups to Allowed Admin Groups
echo
echo "=== Adding Allowed Admin Groups: $groups"
dsconfigad -groups "$existingGroups,$groups"

# Enable Mobile Accounts
echo
echo "=== Enabling Mobile Accounts"
dsconfigad -mobile enable
echo
echo "=== Disabling Mobile Account Creation Confirmation"
dsconfigad -mobileconfirm disable

# Set Search Domains
echo
echo "=== Setting Search Domains"
networksetup -setsearchdomains "USB Ethernet" domain1 domain2 domain3
networksetup -setsearchdomains "Wi-Fi" domain1 domain2 domain3

echo
echo "=== Summary"
newComputerName=$(scutil --get ComputerName)
echo "ComputerName                     = $newComputerName"
newLocalHostName=$(scutil --get LocalHostName)
echo "LocalHostName                    = $newLocalHostName"
newHostName=$(scutil --get HostName)
echo "HostName                         = $newHostName"
echo
echo "== Directory Utility Configuration"
dsconfigad -show | grep "Active Directory"
dsconfigad -show | grep "Computer Account"
echo "Advanced Options - Administrative"
dsconfigad -show | grep "Allowed admin groups"
echo "Mobile Account Options"
dsconfigad -show | grep "Create mobile account at login"
dsconfigad -show | grep "Require confirmation"
echo
echo "== Search Domains"
usbethernet=$(networksetup -getsearchdomains "USB Ethernet" | tr '\n' ', ')
wifi=$(networksetup -getsearchdomains Wi-Fi | tr '\n' ', ')
echo "USB Ethernet                     = $usbethernet"
echo "Wi-Fi                            = $wifi"

echo

exit 0
