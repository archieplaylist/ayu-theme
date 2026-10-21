AC_INIT(
    [ayu-theme],
    [2026.10.2],
    [https://github.com/ayu-theme/ayu-theme/issues],
    [ayu-theme],
    [https://github.com/ayu-theme/ayu-theme],
    []
)

AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([no-dist-gzip dist-xz foreign])
AC_PROG_MKDIR_P

ARC_ENABLE([LIGHT],         [light],         [Ayu Light],   [disable])
ARC_ENABLE([MIRAGE],        [mirage],        [Ayu Mirage],  [disable])
ARC_ENABLE([DARK],          [dark],          [Ayu Dark],    [disable])
ARC_ENABLE([CINNAMON],      [cinnamon],      [Cinnamon],      [disable])
ARC_ENABLE([GNOME_SHELL],   [gnome-shell],   [GNOME Shell],   [disable])
ARC_ENABLE([GTK2],          [gtk2],          [GTK2],          [disable])
ARC_ENABLE([GTK3],          [gtk3],          [GTK3],          [disable])
ARC_ENABLE([GTK4],          [gtk4],          [GTK4],          [disable])
ARC_ENABLE([METACITY],      [metacity],      [Metacity],      [disable])
ARC_ENABLE([UNITY],         [unity],         [Unity],         [disable])
ARC_ENABLE([XFWM],          [xfwm],          [XFWM],          [disable])
ARC_ENABLE([TRANSPARENCY],  [transparency],  [transparency],  [disable])

AS_IF([test "x$ENABLE_GNOME_SHELL$ENABLE_GTK3" != xnono], [ARC_GNOME])
AS_IF([test "x$ENABLE_GTK3$ENABLE_GTK4" != xnono], [ARC_GTK4])

AC_CONFIG_FILES([
    common/Makefile
    extra/Makefile
    Makefile
])

AC_OUTPUT
