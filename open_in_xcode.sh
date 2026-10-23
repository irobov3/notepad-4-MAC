#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
./sync_to_swiftpm.sh

echo "=========================================================="
echo " Notepad++ for iPad Air M3 (11-inch)"
echo "=========================================================="

if [ -d "/Applications/Xcode.app" ]; then
    echo "Opening in Xcode..."
    open -a Xcode NotepadPlusPlus.swiftpm
    echo ""
    echo "In Xcode:"
    echo " 1. Connect your iPad Air M3 via USB-C or ensure Wi-Fi sync is active."
    echo " 2. In the top destination selector, select your connected iPad Air M3."
    echo " 3. Press ⌘R (Run) to build and install Notepad++ directly onto your iPad!"
else
    echo "⚠️  Note: Full Xcode.app was not found in /Applications."
    echo "    (Your Mac currently has Apple Command Line Tools installed)."
    echo ""
    echo "👉 You have 2 great options to run Notepad++ on your iPad Air M3:"
    echo ""
    echo "Option 1 (Instant — No Xcode download required):"
    echo "  Run: ./share_to_ipad.sh"
    echo "  This syncs NotepadPlusPlus directly to your iCloud Drive and reveals it in Finder"
    echo "  for instant AirDrop. On your iPad, open it in the free Apple 'Swift Playgrounds' app and tap Run!"
    echo ""
    echo "Option 2 (Install Xcode on this Mac):"
    echo "  Download Xcode from the Mac App Store:"
    echo "  https://apps.apple.com/app/xcode/id497799835"
    echo "  Then re-run ./open_in_xcode.sh to deploy via USB-C/Wi-Fi."
    echo "=========================================================="
    
    # Offer instant Finder reveal
    open -R NotepadPlusPlus.swiftpm
fi
