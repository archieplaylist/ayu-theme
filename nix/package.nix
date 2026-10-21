{
  lib,
  stdenv,
  autoconf,
  automake,
  pkg-config,
  sassc,
}:

stdenv.mkDerivation {
  pname = "ayu-theme";

  # The version is the one in configure.ac; read it from there so the two
  # cannot drift apart.
  version =
    let
      acInit = builtins.replaceStrings [ "\n" ] [ " " ] (builtins.readFile ../configure.ac);
      matched = builtins.match "AC_INIT[(][[:space:]]*[[]ayu-theme[]],[[:space:]]*[[]([^]]*)[]].*" acInit;
    in
    if matched == null then "0" else builtins.head matched;

  src = lib.cleanSourceWith {
    src = ../.;
    filter = path: type:
      let
        name = baseNameOf (toString path);
      in
      !(lib.elem name [ "node_modules" "dist" ]);
  };

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
    sassc
  ];

  dontConfigure = true;

  enableParallelBuilding = true;

  buildPhase = ''
    runHook preBuild

    # Recompile every stylesheet from the sass sources, exactly like the
    # Docker release build does, so the sass files stay the source of truth.
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
          target=$(basename "$entry" .scss)
          echo "  $dir/$entry -> $target.css"
          sassc "$entry" "../$target.css"
        done
      )
    done

    autoreconf --force --install

    ./configure \
      --prefix="$out" \
      --enable-light \
      --enable-mirage \
      --enable-dark \
      --enable-gtk2 \
      --enable-gtk3 \
      --enable-gtk4 \
      --enable-cinnamon \
      --enable-gnome-shell \
      --enable-metacity \
      --enable-unity \
      --enable-xfwm \
      --with-gnome=3.22 \
      --with-gtk4=4.0

    make -j"$NIX_BUILD_CORES"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make install

    # The autotools install does not cover the extras.
    mkdir -p "$out/share/plank/themes"
    cp -R extra/Ayu-Plank "$out/share/plank/themes/Ayu-Plank"

    mkdir -p "$out/share/ayu-theme/libadwaita"
    cp extra/libadwaita/gtk.css.* "$out/share/ayu-theme/libadwaita/"

    runHook postInstall
  '';

  meta = {
    description = "Ayu GTK theme for GTK 2/3/4, GNOME Shell, Cinnamon, Metacity, Unity and Xfwm4";
    homepage = "https://github.com/archieplaylist/ayu-theme";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
