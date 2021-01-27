# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6	# kernel-2.eclass unsupported for EAPI7
ETYPE="sources"

URELEASE="groovy-updates"
inherit eutils mount-boot kernel-2 versionator ubuntu-versionator

MY_PN="linux"
MY_PV="${PV}"
BASE_PV="5.8.0"	# ${PV} is taken from VERSION,PATCHLEVEL,SUBLEVEL in Makefile
KCONFIG_URELEASE="xenial/linux/4.4.0-185.215"
UURL="mirror://unity/pool/main/l/${MY_PN}"

DESCRIPTION="Ubuntu patched kernel sources"
HOMEPAGE="https://launchpad.net/ubuntu/+source/linux"
SRC_URI="${UURL}/${MY_PN}_${BASE_PV}.orig.tar.gz
	${UURL}/${MY_PN}_${BASE_PV}-${UVER}.diff.gz
	amd64? ( http://kernel.ubuntu.com/~kernel-ppa/configs/${KCONFIG_URELEASE}/amd64-config.flavour.generic )
	x86? ( http://kernel.ubuntu.com/~kernel-ppa/configs/${KCONFIG_URELEASE}/i386-config.flavour.generic )"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="binchecks mirror strip"
S="${WORKDIR}/linux-$(get_version_component_range 1-2)"

pkg_setup() {
	case $ARCH in
		i386)
			defconfig_src=i386
			;;
		amd64)
			defconfig_src=amd64
			;;
		*)
			die "unsupported ARCH: $ARCH"
			;;
	esac
	defconfig_src="${DISTDIR}/${defconfig_src}-config.flavour.generic"
	unset ARCH; unset LDFLAGS # will interfere with Makefile if set
}

src_unpack() {
	unpack ${A}
	epatch_user
}

src_prepare() {
	ubuntu-versionator_src_prepare
	# Ubuntu patchset (don't use epatch so we can easily see what files get patched) #
	cat "${WORKDIR}/${MY_PN}_${BASE_PV}-${UVER}.diff" | patch -p1 || die

	# Fix from LP# 1630990 (header syntax error with !CONFIG_SECURITYFS) #
	sed -e 's/const struct inode_operations \*iops))$/const struct inode_operations *iops)/' \
		-i include/linux/security.h

	# Omit building Ubuntu's VBox kernel modules, these are provided by package app-emulation/virtualbox-modules #
#	epatch -p1 "${FILESDIR}/omit-vbox.diff"

	# Revert kernel commit https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1455cf8dbfd06aa7651dcfccbadb7a093944ca65 #
	#	until systemd, userspace and kernel devs. can arrive at a working solution (broken bluetooth, racing systemd-udevd causing 100% CPU, stale USB devices, etc.) #
	epatch -p1 "${FILESDIR}/revert-bind_unbind-uevents.patch"

	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile || die
	sed -i -e 's:#export\tINSTALL_PATH:export\tINSTALL_PATH:' Makefile || die
	rm -f .config >/dev/null

	# Ubuntu #
	install -d ${TEMP}/configs || die
	make -s mrproper || die "make mrproper failed"

	mv "${TEMP}/configs" "${S}" || die
}

src_install() {
	# copy sources into place #
	dodir /usr/src
	cp -a "${S}" "${D}/usr/src/${PN}-${MY_PV}-${UVER}" || die
	cd "${D}/usr/src/${PN}-${MY_PV}-${UVER}"

	# prepare for real-world use and 3rd-party module building #
	make mrproper || die
	cp $defconfig_src .config || die
	yes "" | make oldconfig || die
}

pkg_postinst() {
	[ ! -e "${ROOT}usr/src/linux" ] && \
		ln -s "${PN}-${MY_PV}-${UVER}" "${ROOT}usr/src/linux"
	elog "Changelog can be found in /usr/src/linux/debian.master/changelog"
}
