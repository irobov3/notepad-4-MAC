#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

APP_PATH="/Applications/NotepadMac.app"
DMG_NAME="Notepad++ for Mac.dmg"
VOL_NAME="Notepad++ for Mac"
STAGING_DIR="dmg_staging"

echo "Creating DMG package for ${VOL_NAME}..."

# Clean old artifacts
rm -rf "${STAGING_DIR}" "${DMG_NAME}"
mkdir -p "${STAGING_DIR}"

# Copy application bundle
cp -R "${APP_PATH}" "${STAGING_DIR}/Notepad++ for Mac.app"

# Create symlink to /Applications for classic drag & drop installation
ln -s /Applications "${STAGING_DIR}/Applications"

# Include custom volume icon
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "${STAGING_DIR}/.VolumeIcon.icns"
    SetFile -a C "${STAGING_DIR}" 2>/dev/null || true
fi

# Build compressed DMG (UDZO)
hdiutil create -volname "${VOL_NAME}" \
               -srcfolder "${STAGING_DIR}" \
               -ov -format UDZO \
               "${DMG_NAME}"

# Clean up temporary staging
rm -rf "${STAGING_DIR}"

echo "=========================================="
echo "DMG Created: $(pwd)/${DMG_NAME}"
ls -lh "${DMG_NAME}"
echo "=========================================="
