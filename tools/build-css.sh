#!/usr/bin/env sh
# Recompile every stylesheet from its Sass sources.
#
#   tools/build-css.sh           # compile in place
#   tools/build-css.sh --check   # fail if a committed .css is out of date
#
# Requires sassc (libsass). Never edit the generated .css files by hand.
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

command -v sassc >/dev/null 2>&1 || { echo "sassc is required" >&2; exit 1; }

status=0
for dir in \
	common/gtk-3.0/3.22/sass \
	common/gtk-4.0/sass \
	common/cinnamon/sass \
	common/gnome-shell/3.22/sass
do
	for entry in "$ROOT/$dir"/*.scss; do
		name=$(basename "$entry" .scss)
		case "$name" in _*) continue ;; esac
		target="$ROOT/$dir/../$name.css"
		if [ "$CHECK" = 1 ]; then
			tmp=$(mktemp)
			(cd "$ROOT/$dir" && sassc "$name.scss" "$tmp")
			if ! cmp -s "$tmp" "$target"; then
				echo "out of date: $dir/../$name.css" >&2
				status=1
			fi
			rm -f "$tmp"
		else
			(cd "$ROOT/$dir" && sassc "$name.scss" "../$name.css")
			echo "  $dir/../$name.css"
		fi
	done
done
exit $status
