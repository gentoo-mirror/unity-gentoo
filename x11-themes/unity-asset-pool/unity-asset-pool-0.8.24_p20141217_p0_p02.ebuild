# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
GCONF_DEBUG="yes"

URELEASE="yakkety"
inherit eutils gnome2 ubuntu-versionator

UURL="mirror://unity/pool/main/u/${PN}"
UVER_PREFIX="+15.04.${PVR_MICRO}"

DESCRIPTION="Unity desktop icon theme"
HOMEPAGE="https://launchpad.net/unity-asset-pool"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="mirror"

RDEPEND="x11-themes/gnome-icon-theme
	x11-themes/hicolor-icon-theme"

DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

S="${WORKDIR}/${PN}-${PV}${UVER_PREFIX}"

src_prepare() { :; }
src_configure() { :; }
src_compile() { :; }

src_install() {
	insinto /usr/share/unity/themes
	doins -r launcher/* panel/*

	insinto /usr/share/icons
	doins -r unity-icon-theme unity-webapps-applications

	insinto /usr/share/icons/hicolor/32x32/apps
	doins account-plugins-icons/*

	insinto /usr/share/icons/hicolor/128x128/apps
	doins unity-webapps-applications/apps/128/*

	dodoc COPYRIGHT
}

pkg_preinst() { gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; }
pkg_postrm() { gnome2_icon_cache_update; }
