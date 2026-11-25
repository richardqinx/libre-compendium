dnl libre-compendium
dnl
dnl Copyright (C) 2026 Richard Qin
dnl
dnl This file is part of libre-compendium.
dnl
dnl libre-compendium is free software: you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation, either version 3 of the License, or
dnl (at your option) any later version.
dnl
dnl libre-compendium is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with libre-compendium.  If not, see <https://www.gnu.org/licenses/>.

AC_INIT([libre-compendium], [0.1.0], [richard.qin.x@gmail.com])
AC_CONFIG_SRCDIR([common/tex/classes/lc-lecture.cls])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([foreign dist-xz tar-pax])
AC_PROG_INSTALL
AC_PROG_MAKE_SET

AC_ARG_WITH([latex-engine],
  [AS_HELP_STRING([--with-latex-engine=ENGINE], [use xelatex or lualatex (default: xelatex)])],
  [DOC_ENGINE=$withval], [DOC_ENGINE=xelatex])
AS_CASE([$DOC_ENGINE], [xelatex|lualatex], [], [AC_MSG_ERROR([unsupported LaTeX engine: $DOC_ENGINE])])
AC_SUBST([DOC_ENGINE])

AC_ARG_ENABLE([html], [AS_HELP_STRING([--disable-html], [disable HTML output])], [], [enable_html=yes])
AC_ARG_ENABLE([svg], [AS_HELP_STRING([--disable-svg], [disable SVG output])], [], [enable_svg=yes])
AC_SUBST([DOC_ENABLE_HTML], [$enable_html])
AC_SUBST([DOC_ENABLE_SVG], [$enable_svg])

AC_PATH_PROG([LATEXMK], [latexmk])
AC_PATH_PROG([MAKE4HT], [make4ht])
AC_PATH_PROG([DVISVGM], [dvisvgm])
AC_PATH_PROG([PDFCAIRO], [pdftocairo])
AS_IF([test "x$DOC_ENGINE" = xxelatex], [AC_PATH_PROG([LATEX_ENGINE_BIN], [xelatex])], [AC_PATH_PROG([LATEX_ENGINE_BIN], [lualatex])])
AS_IF([test -z "$LATEXMK" || test -z "$LATEX_ENGINE_BIN"], [AC_MSG_ERROR([PDF build requires latexmk and $DOC_ENGINE])])
AS_IF([test "x$enable_html" = xyes && test -z "$MAKE4HT"], [AC_MSG_ERROR([HTML build enabled but make4ht was not found])])
AS_IF([test "x$enable_svg" = xyes && test -z "$DVISVGM" && test -z "$PDFCAIRO"], [AC_MSG_ERROR([SVG build enabled but neither dvisvgm nor pdftocairo was found])])

AC_CONFIG_COMMANDS([doc-projects.mk], [
  "$srcdir/build-aux/discover-projects.sh" "$srcdir" "build-aux/doc-projects.mk"
], [srcdir="$srcdir"])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
