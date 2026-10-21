{
  config,
  lib,
  ...
}:

let
  cfg = config.ayu-theme;

  # "Ayu-Dark", "Ayu-Mirage-solid", ...
  themeName = "Ayu-" + lib.capitalize cfg.variant + (lib.optionalString cfg.solid "-solid");

  # The HiDPI window decorations are shipped as a separate theme.
  windowThemeName = themeName + (lib.optionalString cfg.hdpi "-hdpi");

  # libadwaita apps ignore GTK_THEME and only read
  # ~/.config/gtk-4.0/gtk.css, which cannot be set system-wide.
  libadwaitaCss = builtins.readFile ("${../extra/libadwaita}/gtk.css.${cfg.variant}");
in
{
  options.ayu-theme = {
    enable = lib.mkEnableOption "the Ayu GTK theme";

    variant = lib.mkOption {
      type = lib.types.enum [
        "light"
        "mirage"
        "dark"
      ];
      default = "dark";
      description = "The Ayu variant to apply.";
    };

    solid = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Use the non-transparent variants (`Ayu-Dark-solid` and friends)
        instead of the transparent ones.
      '';
    };

    hdpi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Use the HiDPI window decorations (`Ayu-Dark-hdpi` and friends) for
        the window manager. xfwm4 does not load 2x assets automatically.
      '';
    };

    libadwaita = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install the libadwaita named-color overrides in
        `~/.config/gtk-4.0/gtk.css`, so that modern GNOME (libadwaita) apps
        are recoloured as well.
      '';
    };

    gtkTheme = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set `org.gnome.desktop.interface gtk-theme`.";
    };

    colorScheme = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set `org.gnome.desktop.interface color-scheme`.";
    };

    windowTheme = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set `org.gnome.desktop.wm.preferences theme` (xfwm4).";
    };

    shellTheme = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Set `org.gnome.shell.extensions.user-theme name`. This only has an
        effect with the "User Themes" GNOME Shell extension installed.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."gtk-4.0/gtk.css" = lib.mkIf cfg.libadwaita {
      text = libadwaitaCss;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        "gtk-theme" = lib.mkIf cfg.gtkTheme themeName;
        "color-scheme" = lib.mkIf cfg.colorScheme (
          if cfg.variant == "light" then "prefer-light" else "prefer-dark"
        );
      };

      "org/gnome/desktop/wm/preferences" = {
        "theme" = lib.mkIf cfg.windowTheme windowThemeName;
      };

      "org/gnome/shell/extensions/user-theme" = {
        "name" = lib.mkIf cfg.shellTheme themeName;
      };
    };
  };
}
