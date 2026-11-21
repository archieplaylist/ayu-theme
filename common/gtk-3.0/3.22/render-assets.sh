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
INDEX="assets.txt"

mkdir -p "$ASSETS_DIR"

render_one() {
    local id=$1 out=$2 dpi=$3
    if [ -f "$out" ]; then
        echo "$out exists."
        return 0
    fi
    echo "Rendering $out"
    "$INKSCAPE" "${EXTRA_FLAGS[@]}" \
        --export-id="$id" \
        --export-id-only \
        --export-dpi="$dpi" \
        "${EXPORT_FLAG}=${out}" "$SRC_FILE" >/dev/null
    if [ -n "$OPTIPNG" ]; then
        "$OPTIPNG" -o7 --quiet "$out"
    fi
}

while IFS= read -r i; do
    [ -n "$i" ] || continue
    render_one "$i" "$ASSETS_DIR/$i.png" 96
    render_one "$i" "$ASSETS_DIR/$i@2.png" 192
done < "$INDEX"
