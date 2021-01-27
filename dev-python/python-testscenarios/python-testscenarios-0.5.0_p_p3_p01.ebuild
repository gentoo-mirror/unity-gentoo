# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

URELEASE="groovy"
inherit distutils-r1 ubuntu-versionator

UVER="-${PVR_PL_MAJOR}build${PVR_PL_MINOR}"

DESCRIPTION="Python unittest extension for running tests in different scenarios"
HOMEPAGE="https://launchpad.net/testscenarios"
SRC_URI="${UURL}/${MY_P}.orig.tar.xz"

LICENSE="Apache-2.0 BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

S="${WORKDIR}/testscenarios-${PV}"
