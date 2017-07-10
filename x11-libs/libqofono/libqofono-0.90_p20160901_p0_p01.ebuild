# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

URELEASE="zesty"
inherit qmake-utils ubuntu-versionator

UURL="mirror://ubuntu/pool/main/libq/${PN}"
UVER_PREFIX="+16.10.${PVR_MICRO}"

DESCRIPTION="QT library for accessing the ofono daemon, and a declarative plugin for Ofono"
HOMEPAGE="https://github.com/nemomobile/libqofono"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.debian.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="mirror"

DEPEND="dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtdbus:5
	dev-qt/qtxmlpatterns:5
	net-misc/ofono
	test? ( dev-qt/qttest:5 )"

S="${WORKDIR}"

src_prepare() {
	ubuntu-versionator_src_prepare

	# Use system QT prefix for mkspecs installation #
	sed -e 's:QT_INSTALL_PREFIX]/share/qt4:QT_INSTALL_ARCHDATA]:g' \
		-e 's:QT_INSTALL_PREFIX]/share/qt5:QT_INSTALL_ARCHDATA]:g' \
			-i src/src.pro || die

	use test || \
		sed -e 's:test$::g' \
			-i libqofono.pro || die
}

src_configure() {
	eqmake5
}

src_install() {
	emake INSTALL_ROOT="${ED}" install
}
