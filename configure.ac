# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.68])
AC_INIT([firehol],[1.1.1],[firehol-dev@lists.firehol.org])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([autotool])
AC_CONFIG_SRCDIR([sbin/firehol.in])
AM_INIT_AUTOMAKE([gnu])
AM_MAINTAINER_MODE([disable])

# Checks for programs.
AC_PROG_MAKE_SET

if test x"$USE_MAINTAINER_MODE" = xyes; then
AC_MSG_NOTICE(***************** MAINTAINER MODE *****************)
PACKAGE_BUILT_DATE=$(date '+%d %b %Y')
AC_SUBST(PACKAGE_BUILT_DATE)
AX_PROG_XMLLINT([--nonet])
AX_PROG_XSLTPROC([--nonet])
AX_PROG_DBLATEX([])
AX_CHECK_DOCBOOK_DTD([4.5])
AX_CHECK_DOCBOOK_XSLT_MIN([1.76.1])
AX_CHECK_DBLATEX_MIN([0.3.4],[],[AC_MSG_ERROR(could not find required version of DBLaTeX)])
AC_CONFIG_FILES([doc/firehol-manual-info.xml])
AC_MSG_NOTICE(***************************************************)
fi

FIREHOL_CONFIG_DIR=$(eval echo "$sysconfdir/firehol" | sed -e 's/^NONE//')
AC_SUBST(FIREHOL_CONFIG_DIR)

AC_CONFIG_FILES([
	Makefile
	sbin/Makefile
	sbin/firehol
	m4/Makefile
	doc/Makefile
	doc/tools/Makefile
	doc/latex/Makefile
	doc/xsl/Makefile
	doc/reference/Makefile
	doc/man/Makefile
	examples/Makefile
	etc/Makefile
	])

AC_OUTPUT
