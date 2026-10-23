#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
./sync_to_swiftpm.sh

echo "=========================================================="
echo " Preparing Notepad++ for iPad Air M3..."
echo "=========================================================="

ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
if [ -d "$ICLOUD_DIR" ]; then
    echo "Copying NotepadPlusPlus.swiftpm to your iCloud Drive..."
    rm -rf "$ICLOUD_DIR/NotepadPlusPlus.swiftpm"
    cp -r "NotepadPlusPlus.swiftpm" "$ICLOUD_DIR/"
    echo "✅ Synced to iCloud Drive!"
    echo "   On your iPad Air M3: Open 'Files' app -> 'iCloud Drive' -> tap 'NotepadPlusPlus'"
    echo "   (or open Apple Swift Playgrounds and open the project)"
fi

echo ""
echo "Revealing NotepadPlusPlus.swiftpm in Finder for instant AirDrop..."
open -R "NotepadPlusPlus.swiftpm"
echo "✅ Finder opened! You can right-click 'NotepadPlusPlus.swiftpm' -> Share -> AirDrop to your iPad."
echo "=========================================================="
