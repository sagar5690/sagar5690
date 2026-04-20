#!/usr/bin/env bash
set -euo pipefail

APP_NAME="KnockDesk"
BUILD_DIR=".build/release"
DIST_DIR="dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$DIST_DIR"
mkdir -p "$MACOS_DIR" "$RES_DIR"

swift build -c release

cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$APP_NAME</string>
  <key>CFBundleIdentifier</key><string>com.example.knockdesk</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleExecutable</key><string>$APP_NAME</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>KnockDesk listens for desk knocks to trigger your selected action.</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

hdiutil create "$DIST_DIR/$APP_NAME.dmg" -volname "$APP_NAME" -srcfolder "$APP_DIR" -ov -format UDZO

echo "Built: $DIST_DIR/$APP_NAME.dmg"
