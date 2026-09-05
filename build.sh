#!/bin/sh
# Builds ClaudeSwitch.app into ./build with the system Swift toolchain. No Xcode project needed.
set -e
cd "$(dirname "$0")"
APP=build/ClaudeSwitch.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
swiftc -O -swift-version 5 \
    -framework Cocoa -framework Carbon -framework ApplicationServices \
    Sources/*.swift Sources/Terminals/*.swift \
    -o "$APP/Contents/MacOS/ClaudeSwitch"
cp Info.plist "$APP/Contents/Info.plist"
# Ad-hoc signing ("-") changes the app's identity on every build, so macOS
# forgets granted permissions. Export CODESIGN_IDENTITY to a certificate in
# your keychain (self-signed is fine) to keep permissions across rebuilds.
codesign --force --sign "${CODESIGN_IDENTITY:--}" --identifier ai.vguest.claude-switch "$APP"
echo "built $APP"

# ./build.sh --install  copies to /Applications and relaunches the running app.
if [ "$1" = "--install" ]; then
    pkill -x ClaudeSwitch 2>/dev/null || true
    rm -rf /Applications/ClaudeSwitch.app
    cp -R "$APP" /Applications/ClaudeSwitch.app
    open /Applications/ClaudeSwitch.app
    echo "installed and relaunched /Applications/ClaudeSwitch.app"
fi
