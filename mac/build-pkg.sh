#!/bin/bash
# Builds "Catapult-for-Wiicco-<version>.pkg" on a Mac. Run: bash build-pkg.sh
# Optional signing: SIGN_ID="Developer ID Installer: Wiicco (TEAMID)" bash build-pkg.sh
set -euo pipefail
cd "$(dirname "$0")"; source ../client.env
W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
cp -R root "$W/root"; cp -R scripts "$W/scripts"
chmod 755 "$W/scripts/postinstall" "$W"/root/Library/Wiicco/Catapult/*.sh; chmod 644 "$W"/root/Library/LaunchDaemons/*.plist
cp ../assets/Logo.png "$W/root/Library/Wiicco/Catapult/Logo.png"
printf '%s' "$CATAPULT_MAC_URL" > "$W/root/Library/Wiicco/Catapult/catapult-mac-url"
[ -n "$CATAPULT_MAC_URL" ] || echo "NOTE: CATAPULT_MAC_URL is empty: the pkg adds the logo only (Catapult must already be installed)."
OUT="$PWD/Catapult-for-Wiicco-$PKG_VERSION.pkg"
pkgbuild --root "$W/root" --scripts "$W/scripts" --identifier com.wiicco.catapult-client --version "$PKG_VERSION" --install-location / "$W/component.pkg"
cat > "$W/distribution.xml" <<DIST
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="2">
  <title>Catapult for Wiicco</title>
  <welcome file="welcome.html" mime-type="text/html"/>
  <options customize="never" require-scripts="false" hostArchitectures="x86_64,arm64"/>
  <domains enable_localSystem="true"/>
  <choices-outline><line choice="default"><line choice="com.wiicco.catapult-client"/></line></choices-outline>
  <choice id="default"/>
  <choice id="com.wiicco.catapult-client" visible="false"><pkg-ref id="com.wiicco.catapult-client"/></choice>
  <pkg-ref id="com.wiicco.catapult-client" version="$PKG_VERSION" onConclusion="none">component.pkg</pkg-ref>
</installer-gui-script>
DIST
SIGN=(); [ -n "${SIGN_ID:-}" ] && SIGN=(--sign "$SIGN_ID")
productbuild --distribution "$W/distribution.xml" --resources resources --package-path "$W" ${SIGN[@]+"${SIGN[@]}"} "$OUT"
ls -l "$OUT"; echo "Test: sudo installer -pkg \"$OUT\" -target /   Log: /var/log/wiicco-catapult-install.log"
