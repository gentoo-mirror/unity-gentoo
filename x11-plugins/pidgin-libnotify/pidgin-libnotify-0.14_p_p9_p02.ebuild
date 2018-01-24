# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="artful"
inherit autotools eutils ubuntu-versionator

UURL="mirror://unity/pool/main/p/${PN}"

DESCRIPTION="pidgin-libnotify provides popups for pidgin via a libnotify interface"
HOMEPAGE="http://gaim-libnotify.sourceforge.net/"
SRC_URI="${UURL}/${PN}_${PV}.orig.tar.gz
	${UURL}/${MY_P}-${UVER}.debian.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls debug"
RESTRICT="mirror"

RDEPEND=">=x11-libs/libnotify-0.3.2
	net-im/pidgin[gtk]
	unity-indicators/indicator-messages
	x11-libs/gtk+:2"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	ubuntu-versionator_src_prepare

	# Show new conversation popup when enabled by plugin extension #
	#   Libnotify Popups. Make possible to close conversation window #
	#   opened by Unity's Messaging Menu. (LP #1339405) #
	eapply "${FILESDIR}"/fix_popup_and_close.patch

	eautoreconf
}

src_configure() {
	econf \
		--disable-static \
		$(use_enable debug) \
		$(use_enable nls)
}

src_install() {
	emake DESTDIR="${D}" install || die
	find "${D}" -name '*.la' -exec rm -f {} +
	dodoc AUTHORS ChangeLog NEWS README TODO VERSION || die
}
