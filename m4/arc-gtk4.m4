# ARC_GTK4()
# ---------------
AC_DEFUN([ARC_GTK4], [
    PKG_PROG_PKG_CONFIG()

    GTK4_VERSION=""
    AC_ARG_WITH(
        [gtk4],
        [AS_HELP_STRING(
            [--with-gtk4],
            [hard-code the GTK4 CSS flavor for narrow builds; in most cases
             this should follow the distro default, or you can unpack
             different flavors]
        )],
        [GTK4_VERSION="$withval"],
        [PKG_CHECK_EXISTS(
             [gtk4],
             [GTK4_VERSION=`$PKG_CONFIG --modversion gtk4`],
             [AC_MSG_WARN([Could not determine the GTK4 version. Install GTK4 and its development files (libgtk-4-dev for Debian/Ubuntu based distros and gtk4-devel for RPM based distros).])]
         )]
    )

    AS_IF(
        [test -n "$GTK4_VERSION"],
        [AC_MSG_RESULT([Building for GTK4 $GTK4_VERSION])]
    )
])
