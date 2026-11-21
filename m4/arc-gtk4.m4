# ARC_GTK4()
# ---------------
AC_DEFUN([ARC_GTK4], [
    AC_PATH_PROG([PKG_CONFIG], [pkg-config])

    GTK4_VERSION="4.0"
    AC_ARG_WITH(
        [gtk4],
        [AS_HELP_STRING(
            [--with-gtk4],
            [GTK4 CSS version (default: 4.0)]
        )],
        [GTK4_VERSION="$withval"],
        [AS_IF(
            [test -n "$PKG_CONFIG" && "$PKG_CONFIG" --exists gtk4 2>/dev/null],
            [GTK4_VERSION=`"$PKG_CONFIG" --modversion gtk4`]
        )]
    )

    AS_IF(
        [test -n "$GTK4_VERSION"],
        [AC_MSG_RESULT([Building for GTK4 $GTK4_VERSION])]
    )
    AC_SUBST([GTK4_VERSION])
])
