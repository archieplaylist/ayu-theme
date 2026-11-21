#!/usr/bin/env bash
# ----------------------------------------------------------------
# Ayu libadwaita overrides installer
#
# libadwaita apps (modern GTK4 GNOME apps) hard-code Adwaita styles,
# but they DO load `~/.config/gtk-4.0/gtk.css` on top of their theme.
# These overrides re-map libadwaita named colors and CSS variables onto ayu.
#
# Usage:
#   ./install.sh [light|mirage|dark]   (default: detect from current GTK theme / color-scheme)
#   ./install.sh remove                (undo)
# ----------------------------------------------------------------
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GTK4_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-4.0"
CONF_FILE="$GTK4_CONFIG_DIR/gtk.css"
BACKUP_FILE="$GTK4_CONFIG_DIR/gtk.css.ayu-backup"

usage() {
    printf 'Usage: %s [light|mirage|dark|remove]\n' "$0" >&2
}

is_ayu_override() {
    local file=$1 f
    for f in light mirage dark; do
        if cmp -s "$file" "$SELF_DIR/gtk.css.$f"; then
            return 0
        fi
    done
    return 1
}

resolve_flavor() {
    local arg="${1:-}"
    case "$arg" in
        light | mirage | dark | remove)
            echo "$arg"
            ;;
        "")
            local gtk_theme color_scheme
            gtk_theme="$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'" || true)"
            case "$gtk_theme" in
                Ayu-Mirage-solid*|Ayu-Mirage*) echo "mirage"; return 0 ;;
                Ayu-Dark-solid*|Ayu-Dark*)     echo "dark"; return 0 ;;
                Ayu-Light-solid*|Ayu-Light*)   echo "light"; return 0 ;;
            esac
            color_scheme="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'" || true)"
            case "$color_scheme" in
                prefer-dark) echo "dark" ;;
                *)           echo "light" ;;
            esac
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            printf 'error: unknown argument: %s\n' "$arg" >&2
            usage
            exit 1
            ;;
    esac
}

FLAVOR="$(resolve_flavor "${1:-}")"

if [ "$FLAVOR" = "remove" ]; then
    if [ -f "$BACKUP_FILE" ]; then
        mv "$BACKUP_FILE" "$CONF_FILE"
        echo "Restored previous $CONF_FILE"
    elif [ -f "$CONF_FILE" ]; then
        rm "$CONF_FILE"
        echo "Removed $CONF_FILE"
    else
        echo "Nothing to remove"
    fi
    exit 0
fi

mkdir -p "$GTK4_CONFIG_DIR"

if [ -f "$CONF_FILE" ] && ! is_ayu_override "$CONF_FILE"; then
    [ -f "$BACKUP_FILE" ] || cp "$CONF_FILE" "$BACKUP_FILE"
    echo "A previous gtk-4.0 override was found; backup saved to $BACKUP_FILE"
fi

SOURCE_FILE="$SELF_DIR/gtk.css.$FLAVOR"
cp "$SOURCE_FILE" "$CONF_FILE"
echo "Installed $FLAVOR libadwaita overrides -> $CONF_FILE"
echo "Restart running libadwaita apps for changes to take effect"
