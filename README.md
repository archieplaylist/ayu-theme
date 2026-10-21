# Ayu Theme

ayu theme for GTK 4, GTK 3 and GTK 2, based on the flat, transparent Arc theme and recolored with the official [ayu palette](https://github.com/ayu-theme/ayu-colors).

It also themes Cinnamon, GNOME Shell, Metacity, Unity, Xfwm4, Plank and Chrome/Chromium.

Every colour of the theme comes from the official palette: the values in
`tools/palette.json` are generated from ayu-colors and are the single source
of truth for the CSS, the window manager themes and the artwork. See
[PALETTE.md](PALETTE.md) for the mapping and the few documented deviations.

## The theme is available in three variants

##### Ayu Light

##### Ayu Mirage

##### Ayu Dark

## Installation

### Build from source

See *Manual Installation* below. No distro packages exist for this recolored
theme; it must be built from source.

--

### Manual Installation

To build the theme the follwing packages are required 
* `autoconf`
* `automake`
* `pkg-config` or `pkgconfig` for Fedora
* `libgtk-3-dev` for Debian based distros or `gtk3-devel` for RPM based distros
* `libgtk-4-dev` / `gtk4-devel` when building GTK4 support
* `git` to clone the source directory

**Note:** For distributions which don't ship separate development packages, just the GTK 3 package is needed instead of the `-dev` packages.

For the theme to function properly, install the following
* GUI toolkit version requirements: GTK 3.22+ and GTK 4 for the GTK3/GTK4 themes
* GNOME >= 3.22 / Cinnamon >= 3.x for the shell themes (the CSS adapts to
  newer releases; only the 3.22 shell sources are shipped)
* The `gnome-themes-standard` package
* The murrine engine. This has different names depending on the distro.
  * `gtk-engine-murrine` (Arch Linux)
  * `gtk2-engines-murrine` (Debian, Ubuntu, elementary OS)
  * `gtk-murrine-engine` (Fedora)
  * `gtk2-engine-murrine` (openSUSE)
  * `gtk-engines-murrine` (Gentoo)

Install the theme with the following commands

#### 1. Get the source

Clone the git repository with

    git clone <this repository> && cd ayu-theme

#### 2. Build and install the theme

    ./autogen.sh --prefix=/usr
    sudo make install

Other options to pass to autogen.sh are

    --disable-transparency     disable transparency in the GTK3/GTK4 theme
    --disable-light            disable Ayu Light support
    --disable-mirage           disable Ayu Mirage support
    --disable-dark             disable Ayu Dark support
    --disable-cinnamon         disable Cinnamon support
    --disable-gnome-shell      disable GNOME Shell support
    --disable-gtk2             disable GTK2 support
    --disable-gtk3             disable GTK3 support
    --enable-gtk4              enable GTK4 support
    --disable-metacity         disable Metacity support
    --disable-unity            disable Unity support
    --disable-xfwm             disable XFWM support

    --with-gnome=<version>     the GTK3 CSS is shared by every GTK >= 3.22
                               release; the version is detected automatically
                               and any GTK >= 3.22 build uses the 3.22 CSS

After the installation is complete the theme can be activated with `gnome-tweak-tool` or a similar program by selecting `Ayu Light`, `Ayu Mirage` or `Ayu Dark` as Window/GTK+ theme.

If the `--disable-transparency` option was used, the theme will be installed as `Ayu-Light-solid`, `Ayu-Mirage-solid` and `Ayu-Dark-solid`.

Xfwm4 does not automatically load 2x window-decoration assets on HiDPI
displays, so each variant also installs a separate window-manager-only theme
with 2x assets. On a 2x display, select `Ayu-Light-hdpi` (or
`Ayu-Mirage-hdpi`/`Ayu-Dark-hdpi`, and the `-solid-hdpi` names when built
without transparency) as the Xfwm4 window manager theme in addition to the
normal GTK theme.

### Building a release tarball with Docker

`./build-docker.sh` builds the theme in a Debian container (toolchain only — no
host GTK packages needed), recompiles every `.css` from the sass sources, and
packages the result:

    ./build-docker.sh                  # dist/ayu-theme-<version>.tar.gz
    ./build-docker.sh --solid          # dist/ayu-theme-<version>-solid.tar.gz
    ./build-docker.sh --all            # both variants
    ./build-docker.sh -o /tmp/out      # custom output directory

Each tarball contains the theme directories (`Ayu-Light`, `Ayu-Mirage`,
`Ayu-Dark`, or the `-solid` equivalents), plus the `-hdpi` window-manager
themes, ready to extract into `/usr/share/themes`:

    sudo tar -xzf ayu-theme-<version>.tar.gz -C /usr/share/themes

A `.sha256` checksum is written next to each tarball. The build image is
removed afterwards unless `--keep-image` is given.

### GTK4 and libadwaita

The GTK4 theme is installed as `<theme>/gtk-4.0/gtk.css` and is picked up by
GTK4 apps when the theme is selected in `gnome-tweaks` or via
`GTK_THEME=Ayu-Light gtk4-demo`.

Modern libadwaita apps hard-code the Adwaita stylesheet and ignore `GTK_THEME`.
For those, install the ayu named-color overrides (see `extra/libadwaita/`):

    cd extra/libadwaita
    ./install.sh                # auto-detects the flavor; or: light|mirage|dark|remove

To undo:

    ./install.sh remove

## Uninstall

Run

    sudo make uninstall

from the cloned git repository, or

    sudo rm -rf /usr/share/themes/{Ayu-Light,Ayu-Mirage,Ayu-Dark,Ayu-Light-hdpi,Ayu-Mirage-hdpi,Ayu-Dark-hdpi,Ayu-Light-solid,Ayu-Mirage-solid,Ayu-Dark-solid,Ayu-Light-solid-hdpi,Ayu-Mirage-solid-hdpi,Ayu-Dark-solid-hdpi}

## Extras

### Chrome/Chromium theme
The ayu Chrome themes live in `extra/Chrome/{ayu-theme,ayu-mirage-theme,ayu-dark-theme}`.
Modern Chrome no longer accepts unsigned `.crx` files, so pack the theme you
want from its folder via `chrome://extensions` → *Developer mode* → *Pack
extension* (select the `ayu-*-theme` folder as the extension root).

### Plank theme
To install the Plank theme, copy the `extra/Ayu-Plank` folder to `~/.local/share/plank/themes` or to `/usr/share/plank/themes` for system-wide use.
Now open the Plank preferences window by executing `plank --preferences` from a terminal and select `Ayu-Plank` as the theme.

### libadwaita overrides
Named-color overrides that make modern GNOME (libadwaita) apps render in ayu.
See the GTK4 section above, or `extra/libadwaita/install.sh`.

### Asset recolor tools
`tools/recolor-assets.mjs` maps the remaining Arc blue accents in rendered GTK
PNG assets onto the ayu accents. Run it after re-rendering assets with inkscape.
`tools/recolor-titlebuttons.mjs` updates the GTK titlebar button PNGs (close,
maximize, minimize) so the client-side decorations match the xfwm4 assets.

## Troubleshooting

If you get artifacts like black or invisible backgrounds under Unity, disable overlay scrollbars with

    gsettings set com.canonical.desktop.interface scrollbar-mode normal


## Bugs
If you find a bug, please report it at the upstream tracker: https://github.com/jnsh/arc-theme/issues

## License
This theme is based on Arc by horst3180 and is available under the terms of the GPL-3.0. See `COPYING` for details. The ayu palette follows https://github.com/ayu-theme/ayu-colors.

## Full Preview
Run `GTK_THEME=Ayu-Light gtk4-demo` (or open any GTK 3/4 app with `GTK_THEME=...`)
against an installed variant for a live preview.
