#!/bin/bash
# ----------------------------------------------------------------
# Ayu libadwaita overrides installer
#
# libadwaita apps (modern GTK4 GNOME apps) hard-code Adwaita styles,
# but they DO load `~/.config/gtk-4.0/gtk.css` on top of their theme.
# These overrides re-map the libadwaita "named colors" onto ayu.
#
# Usage:
#   ./install.sh [light|mirage|dark]   (default: from current GTK theme or light)
#   ./install.sh remove                (undo)
# ----------------------------------------------------------------
set -e
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GTK4_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-4.0"
CONF_FILE="$GTK4_CONFIG_DIR/gtk.css"
BACKUP_FILE="$HOME/.$(basename "$0").gtk.css.bak"

resolve_flavor() {
    case "$1" in
        light | mirage | dark) echo "$1" ;;
        remove) echo "remove" ;;
        *)
            # Best-effort: use the GTK3 theme name to detect the flavor
            GTK_THEME="$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'\\" || true)"
            case "$GTK_THEME" in
                Ayu-Darkersolid*|Ayu-Darker*) echo "mirage" ;;
                Ayu-Darksolid*|Ayu-Dark*) echo "dark" ;;
                Ayu-solid*) echo "light" ;;
                *) echo "light" ;;
            esac
            ;;
    esac
}

FLAVOR="$(resolve_flavor "$1")"

mkdir -p "$GTK4_CONFIG_DIR"

if [ "$FLAVOR" = "remove" ]; then
    if [ -f "$BACKUP_FILE" ]; then
        mv "$BACKUP_FILE" "$CONF_FILE"
        echo "Restored previous ~/.config/gtk-4.0/gtk.css"
    elif [ -f "$CONF_FILE" ]; then
        rm "$CONF_FILE"
        echo "Removed $CONF_FILE"
    else
        echo "Nothing to remove"
    fi
    exit 0
fi

if [ -f "$CONF_FILE" ] && ! cmp -s "$CONF_FILE" "$SELF_DIR/gtk.css.$FLAVOR"; then
    [ -f "$BACKUP_FILE" ] || cp "$CONF_FILE" "$BACKUP_FILE"
    echo "A previous gtk-4.0 override was found, backup saved"
fi

case "$FLAVOR" in
    light)  SOURCE_FILE="$SELF_DIR/gtk.css.light" ;;
    mirage) SOURCE_FILE="$SELF_DIR/gtk.css.mirage" ;;
    dark)   SOURCE_FILE="$SELF_DIR/gtk.css.dark" ;;
esac

cp "$SOURCE_FILE" "$CONF_FILE"
echo "Installed $FLAVOR libadwaita overrides -> $CONF_FILE"
echo "Log out & back in (or restart the app) for changes to take effect"
