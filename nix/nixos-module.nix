{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ayu-theme;
in
{
  options.services.ayu-theme = {
    enable = lib.mkEnableOption "the Ayu GTK theme";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "ayu-theme";
      description = ''
        The Ayu theme package to install. It provides the `Ayu-Light`,
        `Ayu-Mirage` and `Ayu-Dark` themes (plus their `-hdpi` window
        manager variants) below `share/themes`.
      '';
    };

    murrine = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = ''
        Optional GTK2 theme engine package, e.g. `pkgs.gtk-engine-murrine`
        on nixpkgs versions that still ship it. The GTK2 part of the theme is
        an engine theme and is not rendered without it. GTK2 has been dropped
        from current nixpkgs, hence the default of `null`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # The themes land in /run/current-system/sw/share/themes, which is on
    # XDG_DATA_DIRS in every user session, so GTK, GNOME Shell and xfwm4
    # pick them up.
    environment.systemPackages = [
      cfg.package
    ] ++ lib.optional (cfg.murrine != null) cfg.murrine;
  };
}
