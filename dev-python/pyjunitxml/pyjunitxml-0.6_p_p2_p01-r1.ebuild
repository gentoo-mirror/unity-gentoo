# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{3_7,3_8,3_9} )

URELEASE="groovy"
inherit distutils-r1 ubuntu-versionator

UVER="-${PVR_PL_MAJOR}build${PVR_PL_MINOR}"

DESCRIPTION="PyUnit extension for reporting in JUnit compatible XML"
HOMEPAGE="https://launchpad.net/pyjunitxml"
SRC_URI="${UURL}/${MY_P}.orig.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

S="${WORKDIR}/junitxml-${PV}"
