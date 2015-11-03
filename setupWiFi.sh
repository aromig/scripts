#! /bin/bash

# Script to automate the importation process for wireless certificates on Macs
# Author: Adam Romig
# Actual values redacted

if
	[ "$1" = "" ]
then
	echo
	echo "ERROR: Must run script with arguments."
	echo
	echo "Usage: ./setupWiFi.sh <wirelesscertxxxx.mobileconfig>"
	exit 1
fi

# Definitions
COMPUTERNAME=$(scutil --get ComputerName)

echo

# Make a backup of the Login keychain
echo "=== Backing up Login Keychain"
cp ~/Library/Keychains/login.keychain ~/Library/Keychains/login.keychain-old
echo "~/Library/Keychains/login.keychain -> ~/Library/Keychains/login.keychain-old"

# Install mobileconfig into Profile which adds the certificate
echo "=== Installing $1 into Profiles"
/usr/bin/profiles -IF $1
echo "Done"

# Export certificate and private key with no password
echo "=== Exporting $COMPUTERNAME Certificate & Private Key"
security export -k ~/Library/Keychains/login.keychain -t identities -f pkcs12 -o ~/Desktop/wificert.p12 -P ""

# Restore Login keychain to what it was (security delete-certificate doesn't remove the private key)
echo "=== Restoring Backed Up Login Keychain"
mv ~/Library/Keychains/login.keychain-old ~/Library/Keychains/login.keychain
echo "~/Library/Keychains/login.keychain-old -> ~/Library/Keychains/login.keychain"

# Re-import Certificate back to login keychain
echo "=== Re-Importing $COMPUTERNAME Certificate & Private Key"
security import ~/Desktop/wificert.p12 -k ~/Library/Keychains/login.keychain -xf pkcs12 -P ""

# Delete exported certificate
echo "=== Deleting Exported Certificate ~/Desktop/wificert.p12"
rm ~/Desktop/wificert.p12
echo "Done"

echo
echo "=== WiFi Certificate Set up"
echo
echo "1. Connect to the \"wifi\" access point."
echo "2. Set the Mode to \"EAP-TLS\"."
echo "3. Set the Identity to \"$COMPUTERNAME\"."
echo "4. Set Username to \"host/$COMPUTERNAME\"."
echo "5. Click Join"

echo

exit 0
