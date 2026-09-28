#!/usr/bin/env bash
# Downloads every image the redesign pulls from acprices.com into ./assets
# and rewrites index.html to use the local copies. Run from this folder:
#   bash localize-images.sh
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p assets
cp index.html index.backup.html

grep -oE 'https://acprices\.com/wp-content/uploads/[^"'"'"' )]+\.(png|jpe?g|webp|gif|svg)' index.html | sort -u | while read -r url; do
  name="$(echo "$url" | sed -E 's#.*/uploads/##; s#/#-#g')"
  if [ ! -f "assets/$name" ]; then
    echo "↓ $name"
    curl -fsSL -A "Mozilla/5.0" "$url" -o "assets/$name" || { echo "  ✗ failed: $url"; continue; }
  fi
  # macOS/BSD and GNU sed compatible in-place edit
  sed -i.bak "s#${url}#assets/${name}#g" index.html
done
rm -f index.html.bak
echo "Done. Images in ./assets, index.html updated (original saved as index.backup.html)."
