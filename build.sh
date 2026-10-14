#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
echo "Compiling Notepad++ for Mac (Apple Silicon)..."
swiftc -O -target arm64-apple-macosx14.0 Sources/*.swift -o NotepadMac
mkdir -p /Applications/NotepadMac.app/Contents/MacOS /Applications/NotepadMac.app/Contents/Resources
cp NotepadMac /Applications/NotepadMac.app/Contents/MacOS/NotepadMac
cp Info.plist /Applications/NotepadMac.app/Contents/Info.plist
if [ -f Resources/AppIcon.icns ]; then
    cp Resources/AppIcon.icns /Applications/NotepadMac.app/Contents/Resources/AppIcon.icns
fi
if [ -f Resources/AppIcon.png ]; then
    cp Resources/AppIcon.png /Applications/NotepadMac.app/Contents/Resources/AppIcon.png
fi

# Clean detritus and sign
xattr -cr /Applications/NotepadMac.app
codesign --force --deep --sign - /Applications/NotepadMac.app

# Set workspace icon
swift -e '
import AppKit
let ws = NSWorkspace.shared
if let icon = NSImage(contentsOfFile: "/Users/meha/Desktop/REA/experiments/notepad-mac/Resources/AppIcon.png") {
    _ = ws.setIcon(icon, forFile: "/Applications/NotepadMac.app", options: [])
}
'

/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -f /Applications/NotepadMac.app
echo "Build and installation complete: /Applications/NotepadMac.app"
