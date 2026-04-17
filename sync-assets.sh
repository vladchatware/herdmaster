#!/usr/bin/env bash
# Sync master /Assets/ library → iOS Xcode asset catalog + WebPreview folder
# Run this whenever you add/update assets in /Assets/

set -e
cd "$(dirname "$0")"

MASTER=Assets
IOS_CATALOG=HerdMasterPreview/Assets.xcassets
WEB_ASSETS=WebPreview/assets

echo "Syncing assets from $MASTER → $IOS_CATALOG + $WEB_ASSETS"

# Web preview - simple flat copy
mkdir -p "$WEB_ASSETS/logos" "$WEB_ASSETS/photos" "$WEB_ASSETS/icons" "$WEB_ASSETS/illustrations"
cp -u "$MASTER/Logos/"* "$WEB_ASSETS/logos/" 2>/dev/null || true
cp -u "$MASTER/Photos/"* "$WEB_ASSETS/photos/" 2>/dev/null || true
cp -u "$MASTER/Icons/"* "$WEB_ASSETS/icons/" 2>/dev/null || true
cp -u "$MASTER/Illustrations/"* "$WEB_ASSETS/illustrations/" 2>/dev/null || true

# iOS asset catalog - one .imageset folder per image with Contents.json
# SVGs go in as-is (Xcode 12+ supports SVG vector), PNGs get @1x/@2x/@3x treatment
sync_to_imageset() {
    local src_dir=$1
    for file in "$src_dir"/*.{svg,png,jpg,jpeg,pdf} 2>/dev/null; do
        [ ! -f "$file" ] && continue
        local name=$(basename "$file")
        local stem="${name%.*}"
        local ext="${name##*.}"
        local imageset="$IOS_CATALOG/${stem}.imageset"
        mkdir -p "$imageset"
        cp -u "$file" "$imageset/$name"
        cat > "$imageset/Contents.json" <<JSON
{
  "images" : [
    {
      "filename" : "$name",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }$([ "$ext" = "svg" ] && echo '
  ,"properties" : {
    "preserves-vector-representation" : true
  }')
}
JSON
    done
}

sync_to_imageset "$MASTER/Logos"
sync_to_imageset "$MASTER/Photos"
sync_to_imageset "$MASTER/Icons"
sync_to_imageset "$MASTER/Illustrations"

echo "Done. In Swift: Image(\"<filename-without-extension>\")"
echo "In HTML: <img src=\"assets/<folder>/<filename>\">"
