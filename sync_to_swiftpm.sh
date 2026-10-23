#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
echo "Syncing sources and resources into NotepadPlusPlus.swiftpm..."
mkdir -p NotepadPlusPlus.swiftpm/Sources NotepadPlusPlus.swiftpm/Resources NotepadPlusPlus.swiftpm/.swiftpm/configuration
cp Sources/*.swift NotepadPlusPlus.swiftpm/Sources/
cp -r Resources/* NotepadPlusPlus.swiftpm/Resources/ 2>/dev/null || true
if [ -d Resources/Assets.xcassets ]; then
    cp -r Resources/Assets.xcassets NotepadPlusPlus.swiftpm/Sources/
fi
echo "Sync complete!"
