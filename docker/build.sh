#!/usr/bin/env bash
#
# Build inside the container. Invoked by build-docker.sh; can also be run
# directly with SRC/OUT pointing at mounted directories.
#
#   SRC    source tree (default: /src, read-only is fine)
#   OUT    output directory for the tarball (default: /out)
#   SOLID  1 to build the non-transparent (-solid) variants
#
set -euo pipefail

SRC=${SRC:-/src}
OUT=${OUT:-/out}
SOLID=${SOLID:-0}

BUILD=/tmp/ayu-build
STAGE=/tmp/ayu-stage

say() { printf '\n==> %s\n' "$*"; }

say "Copying sources from $SRC"
rm -rf "$BUILD" "$STAGE"
mkdir -p "$BUILD"
cp -a "$SRC/." "$BUILD/"
cd "$BUILD"
rm -rf node_modules dist .git autom4te.cache build-aux

VERSION=$(awk '
	/^AC_INIT/ { in_init = 1 }
	in_init && /^[[:space:]]*\[[0-9]/ {
		gsub(/[][,[:space:]]/, "")
		print
		exit
	}
' configure.ac)
[ -n "$VERSION" ] || { echo "Could not read version from configure.ac" >&2; exit 1; }

say "Recompiling all CSS from the sass sources"
for dir in \
	common/gtk-3.0/3.22/sass \
	common/gtk-4.0/sass \
	common/cinnamon/sass \
	common/gnome-shell/3.22/sass
do
	(
		cd "$dir"
		for entry in *.scss; do
			case "$entry" in _*) continue ;; esac
			echo "  ${dir}/${entry%.scss}.css"
			sassc "$entry" "../${entry%.scss}.css"
		done
	)
done

say "Running autoreconf"
autoreconf --force --install

CONFIGURE_ARGS=(
	--prefix=/usr
	--enable-light
	--enable-darker
	--enable-dark
	--enable-gtk2
	--enable-gtk3
	--enable-gtk4
	--enable-cinnamon
	--enable-gnome-shell
	--enable-metacity
	--enable-unity
	--enable-xfwm
	--with-gnome=3.22
	--with-gtk4=4.0
)
if [ "$SOLID" = "1" ]; then
	CONFIGURE_ARGS+=(--disable-transparency)
fi

say "Configuring"
./configure "${CONFIGURE_ARGS[@]}"

say "Installing into staging directory"
make install DESTDIR="$STAGE"

THEMEDIR="$STAGE/usr/share/themes"
if [ "$SOLID" = "1" ]; then
	THEMES=(Ayu-solid Ayu-Darker-solid Ayu-Dark-solid)
	HDPI_THEMES=(Ayu-solid-hdpi Ayu-Darker-solid-hdpi Ayu-Dark-solid-hdpi)
	SUFFIX="-solid"
else
	THEMES=(Ayu Ayu-Darker Ayu-Dark)
	HDPI_THEMES=(Ayu-hdpi Ayu-Darker-hdpi Ayu-Dark-hdpi)
	SUFFIX=""
fi

say "Verifying staged themes"
for theme in "${THEMES[@]}"; do
	for f in gtk-2.0/gtkrc gtk-3.0/gtk.css gtk-4.0/gtk.css; do
		[ -f "$THEMEDIR/$theme/$f" ] || { echo "Missing $theme/$f" >&2; exit 1; }
	done
	[ -d "$THEMEDIR/$theme/cinnamon" ] || { echo "Missing $theme/cinnamon" >&2; exit 1; }
	[ -d "$THEMEDIR/$theme/gnome-shell" ] || { echo "Missing $theme/gnome-shell" >&2; exit 1; }
	[ -f "$THEMEDIR/$theme/xfwm4/themerc" ] || { echo "Missing $theme/xfwm4/themerc" >&2; exit 1; }
done

for theme in "${HDPI_THEMES[@]}"; do
	[ -f "$THEMEDIR/$theme/xfwm4/themerc" ] || { echo "Missing $theme/xfwm4/themerc" >&2; exit 1; }
	[ "$(find "$THEMEDIR/$theme/xfwm4" -name '*.png' | wc -l)" -eq 45 ] || {
		echo "Missing xfwm4 HDPI assets in $theme" >&2
		exit 1
	}
done

# Nothing from the original Arc accent may survive into a release artifact.
if grep -rIl --include='*.css' -e '5294e2' -e '5294E2' "$THEMEDIR" >/dev/null 2>&1; then
	echo "Found leftover Arc accent colors in the built CSS" >&2
	exit 1
fi

TARBALL="ayu-theme-${VERSION}${SUFFIX}.tar.gz"
mkdir -p "$OUT"
say "Packaging $TARBALL"
tar --owner=0 --group=0 --numeric-owner \
	-C "$THEMEDIR" \
	-czf "$OUT/$TARBALL" \
	"${THEMES[@]}" "${HDPI_THEMES[@]}"

( cd "$OUT" && sha256sum "$TARBALL" > "$TARBALL.sha256" )

say "Done"
ls -l "$OUT/$TARBALL" "$OUT/$TARBALL.sha256"
