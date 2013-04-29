# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit ubuntu-versionator

UURL="mirror://ubuntu/pool/main/l/${PN}"
URELEASE="quantal"
GNOME2_LA_PUNT="1"

DESCRIPTION="Configuration files to bring up a session with a browser to configure the UCCS service."
HOMEPAGE="https://launchpad.net/lightdm-remote-session-uccsconfigure"
SRC_URI="${UURL}/${MY_P}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
#KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="sys-apps/remote-login-service"
