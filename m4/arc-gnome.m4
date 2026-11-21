# ARC_GNOME()
# ---------------
AC_DEFUN([ARC_GNOME], [
    GNOMEDIR="$srcdir/common/gtk-3.0"
    AC_PATH_PROG([PKG_CONFIG], [pkg-config])
    AC_ARG_WITH(
        [gnome],
        [AS_HELP_STRING(
            [--with-gnome],
            [GNOME/GTK3 version (shared 3.22+ stylesheet)]
        )],
        [GNOME_VERSION="$withval"],
        [AS_IF(
            [test -n "$PKG_CONFIG" && "$PKG_CONFIG" --exists gtk+-3.0 2>/dev/null],
            [GNOME_VERSION=`"$PKG_CONFIG" --modversion gtk+-3.0`],
            [GNOME_VERSION="3.22"]
        )]
    )

    # Only one GTK3 source tree is shipped: the 3.22 CSS works for
    # every GTK >= 3.22 release; older variants were dropped.
    GNOME_VERSMJR=`echo "$GNOME_VERSION" | cut -d. -f1`
    GNOME_VERSMNR=`echo "$GNOME_VERSION" | cut -d. -f2 -s`
    AS_CASE(["$GNOME_VERSMJR.$GNOME_VERSMNR"],
        [3.[0-9]*], [
            AS_IF(
                [test "$GNOME_VERSMNR" -lt 22 2>/dev/null],
                [AC_MSG_NOTICE([GTK 3.$GNOME_VERSMNR detected; using the 3.22 CSS (GTK >= 3.22 is required for correct rendering)])]
            )
        ],
        [4[0-9].*|[34][0-9]], []
    )
    GNOME_VERSION="3.22"

    AS_IF(
        [! test -e "$GNOMEDIR/$GNOME_VERSION"],
        [AC_MSG_ERROR([Invalid GNOME version directory: $GNOMEDIR/$GNOME_VERSION])]
    )
    AC_SUBST([GNOME_VERSION])
    AC_MSG_RESULT([Building for GNOME/GTK3 $GNOME_VERSION])
])
