# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

URELEASE="yakkety"
inherit gnome2-utils qmake-utils ubuntu-versionator

UURL="mirror://unity/pool/main/a/${PN}"
UVER_PREFIX="+16.04.${PVR_MICRO}"

DESCRIPTION="Expose Unity Online Accounts API to QML applications"
HOMEPAGE="https://launchpad.net/accounts-qml-module"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	 ${UURL}/${MY_P}${UVER_PREFIX}-${UVER}${UVER_SUFFIX}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"
RESTRICT="mirror"

DEPEND="dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	unity-base/signon
	x11-libs/libaccounts-qt
	test? ( dev-qt/qttest:5 )"

S="${WORKDIR}/${PN}-${PV}${UVER_PREFIX}"
unset QT_QPA_PLATFORMTHEME

src_prepare() {
	epatch -p1 "${WORKDIR}/${MY_P}${UVER_PREFIX}-${UVER}${UVER_SUFFIX}.diff"
	ubuntu-versionator_src_prepare

	use doc || \
		sed -e '/doc\/doc.pri/d' \
			-i accounts-qml-module.pro
	use test || \
		sed -s '/tests/d' \
			-i accounts-qml-module.pro
}

src_configure() {
	eqmake5
}

src_install() {
	emake INSTALL_ROOT="${ED}" install
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
