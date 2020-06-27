# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="focal"
inherit autotools eutils gnome2-utils ubuntu-versionator vala

UVER_PREFIX="+17.10.${PVR_MICRO}"

DESCRIPTION="System bluetooth indicator used by the Unity desktop"
HOMEPAGE="https://launchpad.net/indicator-bluetooth"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND=">=net-wireless/bluez-5
	media-sound/pulseaudio[bluetooth]"
DEPEND="${RDEPEND}
	dev-libs/glib:2
	dev-libs/libappindicator:=
	dev-libs/libdbusmenu:=
	dev-libs/libindicator:3=
	gnome-base/dconf
	unity-base/unity-control-center
	unity-indicators/ido:=
	x11-libs/gtk+:3
	$(vala_depend)"

S="${WORKDIR}"

src_prepare() {
	ubuntu-versionator_src_prepare

	# Disable url-dispatcher when not using unity8-desktop-session
	eapply "${FILESDIR}/disable-url-dispatcher.diff"

	# Disable all language files as they can be incomplete #
        #  due to being provided by Ubuntu's language-pack packages #
        > po/LINGUAS

	vala_src_prepare
	export VALA_API_GEN="$VAPIGEN"
	eautoreconf
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
	gnome2_schemas_update
}
