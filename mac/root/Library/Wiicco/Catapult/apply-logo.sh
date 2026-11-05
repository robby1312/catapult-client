#!/bin/bash
# Keeps the Wiicco logo in the Catapult app (runs as root via LaunchDaemon com.wiicco.catapult-logo).
SRC=/Library/Wiicco/Catapult/Logo.png
APP=/Applications/Catapult.app
DEST="$APP/Contents/MacOS/Logo.png"
[ -d "$APP/Contents/MacOS" ] && [ -f "$SRC" ] || exit 0
cmp -s "$SRC" "$DEST" && exit 0
install -m 644 "$SRC" "$DEST" && logger -t wiicco-catapult "Wiicco logo applied to $APP"
