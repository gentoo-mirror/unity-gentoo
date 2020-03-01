# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="eoan"
inherit cmake-utils gnome2-utils ubuntu-versionator

UVER_PREFIX="+${UVER_RELEASE}.${PVR_MICRO}"

DESCRIPTION="Date and Time Indicator used by the Unity desktop"
HOMEPAGE="https://launchpad.net/indicator-datetime"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
#KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="mirror"

COMMON_DEPEND="
	dev-libs/libaccounts-glib
	dev-libs/libdbusmenu:=
	dev-libs/libtimezonemap:=
	media-libs/gstreamer:1.0
	sys-apps/util-linux
	unity-indicators/ido:=
	unity-indicators/indicator-messages
	>=x11-libs/libnotify-0.7.6

	gnome-extra/evolution-data-server:=
	test? ( >=dev-cpp/gtest-1.8.1 )"

RDEPEND="${COMMON_DEPEND}
	unity-base/unity-language-pack"
DEPEND="${COMMON_DEPEND}
	dev-libs/properties-cpp"
# PDEPEND to avoid circular dependency
PDEPEND="unity-base/unity-control-center"

S="${WORKDIR}/${PN}-${PV}${UVER_PREFIX}"
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	ubuntu-versionator_src_prepare
	eapply "${FILESDIR}/01-${PN}-remove-url-dispatcher_17.10.patch"
#	eapply "${FILESDIR}/02-${PN}-optional-eds_17.10.patch"	## FIXME

	# Fix schema errors and sandbox violations #
	sed -e 's:SEND_ERROR:WARNING:g' \
		-e '/Compiling GSettings schemas/,+1 d' \
			-i cmake/UseGSettings.cmake

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	sed -i \
		-e "/add_subdirectory(po)/d" \
		CMakeLists.txt

	# Disable tests #
	use test || sed -i \
		-e "/enable_testing()/d" \
		-e "/add_subdirectory(tests)/d" \
		CMakeLists.txt

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_FULL_LOCALEDIR=/usr/share/locale
	)
	cmake-utils_src_configure
}

pkg_preinst() {
        gnome2_schemas_savelist
        gnome2_icon_savelist
}
pkg_postinst() {
	gnome2_schemas_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_schemas_update
	gnome2_icon_cache_update
}
