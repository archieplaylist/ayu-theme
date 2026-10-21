This theme uses `sassc` (libsass) to process the various .scss files. Never edit any of the .css files manually.

#### Editing the CSS based themes in the `common` directory (gtk-3.0, gtk-4.0, cinnamon, gnome-shell)

* Install `sassc` (Debian: `apt install sassc`, Fedora: `dnf install sassc`)

* Edit the `common/gtk-3.0/3.22/sass/*.scss`, `common/gtk-4.0/sass/*.scss`,
  `common/cinnamon/sass/*.scss` and/or `common/gnome-shell/3.22/sass/*.scss` files

* Regenerate the CSS. From within a `sass` directory, compile every entry point one level up, for example:

  ```sh
  cd common/gtk-3.0/3.22/sass
  for f in gtk gtk-dark gtk-mirage gtk-solid gtk-solid-dark gtk-solid-mirage; do
      sassc "$f.scss" "../$f.css"
  done
  ```

  Cinnamon and GNOME Shell have three entry points each:

  ```sh
  cd common/cinnamon/sass
  for f in cinnamon cinnamon-dark cinnamon-mirage; do sassc "$f.scss" "../$f.css"; done

  cd common/gnome-shell/3.22/sass
  for f in gnome-shell gnome-shell-dark gnome-shell-mirage; do sassc "$f.scss" "../$f.css"; done
  ```

* Colors live in `_colors.scss`. Each flavor (`Ayu Light`, `Ayu Mirage`,
  `Ayu Dark`) is selected by the `$flavor` variable set in the entry
  `.scss` files; `$variant` and `$transparency` behave like they did in Arc.

* The palette itself is **not** written by hand. `tools/palette.json` holds the
  official ayu-colors values, `tools/gen-palette.mjs` writes them into the
  `$ayu` map of every Sass tree, and `tools/check-palette.mjs` fails when a
  colour is not an ayu token. See `PALETTE.md`.

  ```sh
  node tools/gen-palette.mjs      # regenerate the $ayu blocks
  node tools/check-palette.mjs    # verify that everything is an ayu colour
  ```

  The generated block is delimited by `// BEGIN AYU PALETTE` and
  `// END AYU PALETTE`; never edit it by hand.

Note: the GTK3 and GNOME Shell CSS are shared by every GTK >= 3.22 / GNOME >= 3.22
release; separate version directories for 3.14–3.20 were dropped.

--

#### Editing the GTK 2 themes

* Go to `common/gtk-2.0`

* The colors are defined in `gtkrc`, `gtkrc-dark` and `gtkrc-mirage` (light / dark / mirage)

* `main.rc` contains the major part of the theme

* `panel.rc` contains the panel styling for Xfce and MATE

* `apps.rc` contains some application specific rules

Because this theme is heavily based on the pixmap engine, a lot of the styling comes from the images in the `assets` and `assets-dark` folders. Don't edit these images directly. See the next section.

--

#### Editing the images for the GTK 2, GTK 3 and GTK 4 themes

* Go to the `common/gtk-2.0` or `common/gtk-3.0/3.22` directory
  (`common/gtk-4.0/assets` reuses the GTK3 assets)

* Open the `assets.svg` file in inkscape. Each object in the .svg file corresponds to an image in the `assets` folder

* Find the object you want to edit and make your changes. Important: Don't change the object id!

* Save `assets.svg` and delete the images corresponding to the edited .svg objects from the `assets` folder (or just delete everything in the `assets` folder). Copy updated PNGs to `common/gtk-4.0/assets` as well.

* Run `./render-assets.sh` or `./render-dark-assets.sh` from a terminal

* The `assets.svg` sources and the PNGs are already ayu-colored in this tree,
  so a fresh render normally needs no extra pass. If you bring in new artwork
  from Arc, re-run the colour map over both the sources and the rendered PNGs:

  ```sh
  npm i
  node tools/recolor-svg.mjs      # SVG/XML sources
  node tools/recolor-assets.mjs   # rendered PNGs
  ```

  The mapping is defined in `tools/asset-map.json` and points at the official
  ayu colours: the accents become `#035BD6` (light) or `#E6B450` (dark), the
  window-button close states use the ayu red ramp, and the widget chrome uses
  the ayu surfaces and gray ramp. Both scripts write exact colours and are
  idempotent, so running them twice changes nothing.

  `tools/check-palette.mjs` fails if a legacy Arc colour is left in a
  rendered asset.

* Cinnamon and GNOME Shell assets are plain SVG and are recolored by
  `tools/recolor-svg.mjs` as well. Accent-bearing assets that are shared
  between variants live in `light-assets/`/`dark-assets/` so the light theme
  gets ayu blue and the dark/mirage themes get ayu yellow.

* The GTK titlebar button PNGs are kept in sync with the xfwm4 decorations by
  `tools/recolor-titlebuttons.mjs`. Run it after re-rendering the titlebutton
  assets; it updates both the normal and `@2` files in
  `gtk-3.0/3.22/assets` and `gtk-4.0/assets`.

--

#### Editing the Xfwm4 window decoration

* The xfwm4 assets are generated from `common/xfwm4/assets.svg` (light),
  `assets-dark.svg` (dark) and `assets-mirage.svg` (mirage). The SVGs are
  already ayu-colored; keep the palette in sync with `_colors.scss` when you
  bring in new artwork from Arc.

* `./render-assets.sh` renders all 45 assets for each variant into `assets/`,
  `assets-dark/` and `assets-mirage/`, and the 2x versions into
  `assets-hdpi/`, `assets-dark-hdpi/` and `assets-mirage-hdpi/`. It works with
  Inkscape 1.x and 0.92; `optipng` is used when available.

* The window-manager-only `*-hdpi` themes are installed from the 2x trees.
  `themerc-hdpi`, `themerc-dark-hdpi` and `themerc-mirage-hdpi` double the
  pixel geometry (button spacing, title offset, shadow and top border).

--

#### libadwaita overrides

The GTK4 theme itself also covers most libadwaita apps when it is selected via
`GTK_THEME`. For apps that hard-code Adwaita and ignore `GTK_THEME`, the
named-color overrides in `extra/libadwaita/` can be installed into
`~/.config/gtk-4.0/gtk.css`:

```sh
cd extra/libadwaita
./install.sh            # detects the current flavor, or use: light|mirage|dark|remove
```
