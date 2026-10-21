#!/usr/bin/env bash
#
# Render the xfwm4 PNG assets from the SVG sources.
#
# Inkscape 1.x and 0.92 are both supported. The HiDPI trees use the same
# filenames at 2x dimensions; install them under the separate *-hdpi window
# manager themes (xfwm4 does not auto-load @2 assets).
#
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

INKSCAPE=${INKSCAPE:-inkscape}
OPTIPNG=${OPTIPNG:-optipng}
INDEX=assets.txt

if "$INKSCAPE" --version 2>/dev/null | grep -Eq '^Inkscape 1\.'; then
	EXPORT_OPT=--export-filename
else
	EXPORT_OPT=--export-png
fi

render() {
	local src=$1 outdir=$2 dpi=$3 id

	mkdir -p "$outdir"
	while IFS= read -r id; do
		[ -n "$id" ] || continue
		echo "Rendering $outdir/$id.png"
		"$INKSCAPE" --export-id="$id" --export-id-only \
			--export-dpi="$dpi" "$EXPORT_OPT=$outdir/$id.png" "$src" >/dev/null
		if command -v "$OPTIPNG" >/dev/null 2>&1; then
			"$OPTIPNG" -o7 --quiet "$outdir/$id.png"
		fi
	done < "$INDEX"
}

render assets.svg		assets			96
render assets-dark.svg		assets-dark		96
render assets-darker.svg	assets-darker		96
render assets.svg		assets-hdpi		192
render assets-dark.svg		assets-dark-hdpi	192
render assets-darker.svg	assets-darker-hdpi	192
