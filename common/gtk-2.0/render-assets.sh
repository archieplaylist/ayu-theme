#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

INKSCAPE="${INKSCAPE:-$(command -v inkscape || true)}"
OPTIPNG="${OPTIPNG:-$(command -v optipng || true)}"

[ -n "$INKSCAPE" ] || { echo "inkscape is required" >&2; exit 1; }

if "$INKSCAPE" --version 2>/dev/null | grep -Eq '^Inkscape [1-9]\.'; then
    EXPORT_FLAG="--export-filename"
    EXTRA_FLAGS=()
else
    EXPORT_FLAG="--export-png"
    EXTRA_FLAGS=(-z)
fi

SRC_FILE="assets.svg"
ASSETS_DIR="assets"
DARK_SRC_FILE="assets-dark.svg"
DARK_ASSETS_DIR="assets-dark"
INDEX="assets.txt"

mkdir -p "$ASSETS_DIR" "$DARK_ASSETS_DIR" menubar-toolbar

render_one() {
    local id=$1 src=$2 out=$3
    if [ -f "$out" ]; then
        echo "$out exists."
        return 0
    fi
    echo "Rendering $out"
    "$INKSCAPE" "${EXTRA_FLAGS[@]}" \
        --export-id="$id" \
        --export-id-only \
        "${EXPORT_FLAG}=${out}" "$src" >/dev/null
    if [ -n "$OPTIPNG" ]; then
        "$OPTIPNG" -o7 --quiet "$out"
    fi
}

while IFS= read -r i; do
    [ -n "$i" ] || continue
    render_one "$i" "$SRC_FILE" "$ASSETS_DIR/$i.png"
    render_one "$i" "$DARK_SRC_FILE" "$DARK_ASSETS_DIR/$i.png"
done < "$INDEX"

cp "$ASSETS_DIR/entry-toolbar.png" menubar-toolbar/entry-toolbar.png
cp "$ASSETS_DIR/entry-active-toolbar.png" menubar-toolbar/entry-active-toolbar.png
cp "$ASSETS_DIR/entry-disabled-toolbar.png" menubar-toolbar/entry-disabled-toolbar.png
cp "$ASSETS_DIR/menubar.png" menubar-toolbar/menubar.png
cp "$ASSETS_DIR/menubar_button.png" menubar-toolbar/menubar_button.png

cp "$DARK_ASSETS_DIR/button.png" menubar-toolbar/button.png
cp "$DARK_ASSETS_DIR/button-hover.png" menubar-toolbar/button-hover.png
cp "$DARK_ASSETS_DIR/button-active.png" menubar-toolbar/button-active.png
cp "$DARK_ASSETS_DIR/button-insensitive.png" menubar-toolbar/button-insensitive.png
cp "$DARK_ASSETS_DIR/entry-toolbar.png" menubar-toolbar/entry-toolbar-dark.png
cp "$DARK_ASSETS_DIR/entry-active-toolbar.png" menubar-toolbar/entry-active-toolbar-dark.png
cp "$DARK_ASSETS_DIR/entry-disabled-toolbar.png" menubar-toolbar/entry-disabled-toolbar-dark.png
cp "$DARK_ASSETS_DIR/menubar.png" menubar-toolbar/menubar-dark.png
cp "$DARK_ASSETS_DIR/menubar_button.png" menubar-toolbar/menubar_button-dark.png

if command -v node >/dev/null 2>&1 && [ -f ../../tools/gen-gtk2-sidebar-assets.mjs ]; then
    node ../../tools/gen-gtk2-sidebar-assets.mjs
fi
