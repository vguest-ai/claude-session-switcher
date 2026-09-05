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
