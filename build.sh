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
codesign --force --sign - --identifier ai.vguest.claude-switch "$APP"
echo "built $APP"

# ./build.sh --install  copies to /Applications and relaunches the running app.
if [ "$1" = "--install" ]; then
    pkill -x ClaudeSwitch 2>/dev/null || true
    rm -rf /Applications/ClaudeSwitch.app
    cp -R "$APP" /Applications/ClaudeSwitch.app
    open /Applications/ClaudeSwitch.app
    echo "installed and relaunched /Applications/ClaudeSwitch.app"
fi
