# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

URELEASE="yakkety"
inherit gnome2 ubuntu-versionator

UURL="mirror://unity/pool/main/g/${PN}"

DESCRIPTION="Collection of GSettings schemas for GNOME desktop"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="${UURL}/${MY_P}.orig.tar.xz
	${UURL}/${MY_P}-${UVER}.debian.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="+introspection"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

RDEPEND="dev-libs/glib:2
	introspection? ( dev-libs/gobject-introspection )
	unity-base/ubuntu-settings
	x11-themes/gnome-backgrounds
	x11-themes/gtk-engines-unico
	x11-themes/ubuntu-themes
	x11-themes/ubuntu-wallpapers"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

src_prepare() {
	ubuntu-versionator_src_prepare
	gnome2_src_prepare
}

src_configure() {
	DOCS="AUTHORS HACKING NEWS README"
	gnome2_src_configure $(use_enable introspection)
}
