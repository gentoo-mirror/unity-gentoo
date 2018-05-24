# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="bionic"
inherit autotools flag-o-matic gnome2-utils ubuntu-versionator vala

UVER_PREFIX="+${UVER_RELEASE}.${PVR_MICRO}"

DESCRIPTION="The greeter (login screen) application for Unity. It is implemented as a LightDM greeter."
HOMEPAGE="https://launchpad.net/unity-greeter"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="accessibility battery +branding networkmanager nls"
RESTRICT="mirror"

DEPEND="dev-libs/libindicator
	gnome-base/gnome-desktop:3=
	media-libs/freetype:2
	media-libs/libcanberra
	unity-base/unity-settings-daemon
	unity-indicators/ido
	x11-libs/cairo
	x11-libs/gtk+:3
	>=x11-misc/lightdm-1.4.0
	$(vala_depend)"

RDEPEND="accessibility? ( app-accessibility/onboard
			app-accessibility/orca )
	battery? ( unity-indicators/indicator-power )
	networkmanager? ( >=gnome-extra/nm-applet-0.9.8.0 )
	>=app-eselect/eselect-lightdm-0.1
	>=gnome-base/gsettings-desktop-schemas-3.8
	media-fonts/ubuntu-font-family
	sys-auth/polkit-pkla-compat
	unity-base/unity-language-pack
	unity-indicators/indicator-session
	unity-indicators/indicator-datetime
	unity-indicators/indicator-sound
	unity-indicators/indicator-application
	x11-themes/ubuntu-wallpapers"

S="${WORKDIR}/${PN}-${PV}${UVER_PREFIX}"

src_prepare() {
	ubuntu-versionator_src_prepare

	# import environment variables before indicator-keyboard starts
	#  (fix keyboard layout to correspond with indicator-keyboard icon)
	eapply "${FILESDIR}"/environment-variables.patch

	# patch 'at-spi-bus-launcher' path
	sed -i -e "s:/usr/lib/at-spi2-core/at-spi-bus-launcher:/usr/libexec/at-spi-bus-launcher:" \
                  "${S}"/src/unity-greeter.vala || die

	vala_src_prepare
	append-cflags -Wno-error
	eautoreconf
}

src_configure() {
	econf $(use_enable nls)
}

src_install() {
	emake DESTDIR="${ED}" install

	# Remove all installed language files as they can be incomplete #
	# due to being provided by Ubuntu's language-pack packages #
	rm -rf "${ED}usr/share/locale"

	# Branding #
	insinto /usr/share/unity-greeter
	newins "${FILESDIR}/gentoo_logo.png" logo.png
	if use branding; then
		newins "${FILESDIR}/gentoo_cof.png" cof.png # Gentoo logo for multi monitor usage #
	else
		insinto /usr/share/glib-2.0/schemas
		doins "${FILESDIR}/50_unity-greeter.gschema.override"
	fi

	# Install polkit privileges config #
	insinto /var/lib/polkit-1/localauthority/10-vendor.d
	doins debian/unity-greeter.pkla
	fowners root:polkitd /var/lib/polkit-1/localauthority/10-vendor.d/unity-greeter.pkla

	prune_libtool_files --modules
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update

	elog "Setting ${PN} as default greeter of LightDM."
	"${ROOT}"/usr/bin/eselect lightdm set unity-greeter

	elog "Setting 'unity' as default user session."
	if line=$(grep -s -m 1 -e "user-session" "/etc/lightdm/lightdm.conf"); then
		sed -i -e "s/user-session=.*/user-session=unity/" "/etc/lightdm/lightdm.conf"
	else
		echo "user-session=unity" >> "${EROOT}/etc/lightdm/lightdm.conf"
	fi
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
	if [ -e /usr/libexec/lightdm/lightdm-set-defaults ]; then
		elog "Removing ${PN} as default greeter of LightDM"
		/usr/libexec/lightdm/lightdm-set-defaults --remove --greeter=${PN}
		/usr/libexec/lightdm/lightdm-set-defaults --remove --session=unity
	fi
	gnome2_schemas_update
}
