#!/bin/bash
# Removes the Wiicco logo service and logo (the Catapult app itself stays). Run: sudo bash /Library/Wiicco/Catapult/uninstall.sh
launchctl bootout system /Library/LaunchDaemons/com.wiicco.catapult-logo.plist 2>/dev/null || true
rm -f /Library/LaunchDaemons/com.wiicco.catapult-logo.plist /Applications/Catapult.app/Contents/MacOS/Logo.png
rm -rf /Library/Wiicco/Catapult
pkgutil --forget com.wiicco.catapult-client >/dev/null 2>&1 || true
echo "Wiicco Catapult branding removed."
