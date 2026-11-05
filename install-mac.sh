#!/bin/bash
# Catapult for Wiicco - one-line Mac installer:
#   curl -fsSL https://raw.githubusercontent.com/robby1312/catapult-client/main/install-mac.sh | bash
# Installs the official Catapult client from XDT (if missing), the Wiicco logo, and a background
# service that puts the logo back after every Catapult update. Remove: add "-s -- --remove".
set -euo pipefail
RAW=https://raw.githubusercontent.com/robby1312/catapult-client/main
DIR=/Library/Wiicco/Catapult
PLIST=/Library/LaunchDaemons/com.wiicco.catapult-logo.plist

if [ "${1:-}" = "--remove" ]; then
  [ -f "$DIR/uninstall.sh" ] && sudo bash "$DIR/uninstall.sh" || echo "Nothing to remove."; exit 0
fi

echo "Catapult for Wiicco: this asks for your Mac password once."
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
curl -fsSL -o "$T/Logo.png"       "$RAW/assets/Logo.png"
curl -fsSL -o "$T/apply-logo.sh"  "$RAW/mac/root/Library/Wiicco/Catapult/apply-logo.sh"
curl -fsSL -o "$T/uninstall.sh"   "$RAW/mac/root/Library/Wiicco/Catapult/uninstall.sh"
curl -fsSL -o "$T/logo.plist"     "$RAW/mac/root/Library/LaunchDaemons/com.wiicco.catapult-logo.plist"
curl -fsSL -o "$T/postinstall"    "$RAW/mac/scripts/postinstall"
URL=$(curl -fsSL "$RAW/client.env" | sed -n 's/^CATAPULT_MAC_URL="\([^"]*\)".*/\1/p')

sudo mkdir -p "$DIR"
sudo install -m 644 "$T/Logo.png" "$DIR/Logo.png"
sudo install -m 755 "$T/apply-logo.sh" "$T/uninstall.sh" "$DIR/"
sudo install -m 644 -o root -g wheel "$T/logo.plist" "$PLIST"
printf '%s' "$URL" | sudo tee "$DIR/catapult-mac-url" >/dev/null
osascript -e 'quit app "Catapult"' 2>/dev/null || true
sudo bash "$T/postinstall"
sudo tail -4 /var/log/wiicco-catapult-install.log
[ -f /Applications/Catapult.app/Contents/MacOS/Logo.png ] && { echo "Done. Starting Catapult."; open -a /Applications/Catapult.app; } || echo "Catapult not found: see /var/log/wiicco-catapult-install.log"
