# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{3_6,3_7} )
PYTHON_REQ_USE="xml"

URELEASE="eoan"
inherit gnome2 meson python-single-r1 toolchain-funcs versionator ubuntu-versionator

UVER="-1"

DESCRIPTION="Introspection infrastructure for generating gobject library bindings for various languages"
HOMEPAGE="https://wiki.gnome.org/Projects/GObjectIntrospection"
SRC_URI="mirror://gnome/sources/${PN}/1.$(get_version_component_range 2)/${P}.tar.xz"
LICENSE="LGPL-2+ GPL-2+"
SLOT="0"
#KEYWORDS="~amd64 ~x86"
IUSE="cairo doctool test"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	test? ( cairo )
"
# virtual/pkgconfig needed at runtime, bug #505408
# We force glib and goi to be in sync by this way as explained in bug #518424
RDEPEND="
	>=dev-libs/gobject-introspection-common-${PV}
	>=dev-libs/glib-2.$(get_version_component_range 2):2
	doctool? ( dev-python/mako )
	virtual/libffi:=
	!<dev-lang/vala-0.20.0
	${PYTHON_DEPS}
"
# Wants real bison, not virtual/yacc
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.19
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
"
# PDEPEND to avoid circular dependencies, bug #391213
PDEPEND="cairo? ( x11-libs/cairo[glib] )"

pkg_setup() {
	ubuntu-versionator_pkg_setup
	python-single-r1_pkg_setup
}

src_configure() {
	if ! has_version "x11-libs/cairo[glib]"; then
		# Bug #391213: enable cairo-gobject support even if it's not installed
		# We only PDEPEND on cairo to avoid circular dependencies
		export CAIRO_LIBS="-lcairo -lcairo-gobject"
		export CAIRO_CFLAGS="-I${EPREFIX}/usr/include/cairo"
	fi

	# To prevent crosscompiling problems, bug #414105
	local emesonargs=(
		-Dcairo=$(usex cairo true false) \
		-Ddoctool=$(usex doctool true false) \
		-Dgtk_doc=$(usex doctool true false) \
		-Dpython=python3
	)
	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	python_fix_shebang "${BUILD_DIR}/tools/g-ir-annotation-tool"
	python_fix_shebang "${BUILD_DIR}/tools/g-ir-scanner"
	meson_src_install

	# Prevent collision with gobject-introspection-common
	rm -v "${ED}"usr/share/aclocal/introspection.m4 \
		"${ED}"usr/share/gobject-introspection-1.0/Makefile.introspection || die
	rmdir "${ED}"usr/share/aclocal || die

	prune_libtool_files --modules
}
