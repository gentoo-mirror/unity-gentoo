# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

URELEASE="zesty"
inherit cmake-utils ubuntu-versionator

UURL="mirror://unity/pool/main/u/${PN}"
UVER_PREFIX="+${UVER_RELEASE}.${PVR_MICRO}"

DESCRIPTION="API for Unity shell integration"
HOMEPAGE="https://launchpad.net/unity-api"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="mirror"

DEPEND="dev-libs/boost:=
	dev-libs/glib:2
	dev-libs/libqtdbustest
	dev-qt/qtdeclarative
	test? ( dev-util/cppcheck )"

S="${WORKDIR}"
export QT_SELECT=5

src_prepare() {
	sed -e 's:set(LIB_INSTALL_PREFIX lib/${CMAKE_LIBRARY_ARCHITECTURE}):set(LIB_INSTALL_PREFIX ${CMAKE_INSTALL_LIBDIR}):g' \
	-i ${S}/CMakeLists.txt || die

	cmake-utils_src_prepare
}
