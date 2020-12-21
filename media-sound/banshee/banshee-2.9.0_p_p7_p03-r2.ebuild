# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="cosmic"
inherit eutils autotools mono-env gnome2-utils versionator ubuntu-versionator xdg-utils

UVER_PREFIX="+really2.6.2"

DESCRIPTION="Import, organize, play, and share your music (patched for Unity)"
HOMEPAGE="http://banshee.fm/"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.xz
	${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.debian.tar.xz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+aac +cdda +bpm daap doc +encode ipod karma mtp test udev youtube"
RESTRICT="mirror"

RDEPEND="dev-lang/mono
	gnome-base/gnome-settings-daemon
	sys-apps/dbus
	>=dev-dotnet/gtk-sharp-2.12.21:2
	dev-dotnet/notify-sharp
	media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0
	media-libs/gst-plugins-bad:1.0
	media-libs/gst-plugins-good:1.0
	media-libs/gst-plugins-ugly:1.0
	media-plugins/gst-plugins-meta:1.0
	cdda? (
		|| (
			media-plugins/gst-plugins-cdparanoia:1.0
			media-plugins/gst-plugins-cdio:1.0
		)
	)
	media-libs/musicbrainz:3
	dev-dotnet/dbus-sharp:1.0
	dev-dotnet/dbus-sharp-glib:1.0
	dev-dotnet/mono-addins[gtk]
	dev-dotnet/taglib-sharp
	dev-db/sqlite:3
	karma? ( media-libs/libkarma )
	aac? ( media-plugins/gst-plugins-faad:1.0 )
	bpm? ( media-plugins/gst-plugins-soundtouch:1.0 )
	daap? (	dev-dotnet/mono-zeroconf )
	doc? (
		app-text/gnome-doc-utils
	)
	encode? (
		media-plugins/gst-plugins-lame:1.0
		media-plugins/gst-plugins-taglib:1.0
	)
	ipod? ( media-libs/libgpod[mono] )
	mtp? (
		media-libs/libmtp
	)
	youtube? (
		dev-dotnet/google-gdata-sharp
	)
	udev? (
		app-misc/media-player-info
		dev-dotnet/gio-sharp
		dev-dotnet/gkeyfile-sharp
		dev-dotnet/gtk-sharp-beans
		dev-dotnet/gudev-sharp
	)"
## Upstream net-libs/webkit-gtk is an API mess with multiple vulnerabilities, disabled for now ##
#	web? (
#		net-libs/webkit-gtk:2
#		net-libs/libsoup:2.4
#	)
DEPEND="${RDEPEND}
	virtual/pkgconfig"
S="${WORKDIR}/${PN}-2.6.2"

src_prepare () {
	# remove dedirection over ubuntu servers since it doesn't work any more
	sed -i '/Change-Amazon-redirect-url/d' "${WORKDIR}/debian/patches/series" || die
	ubuntu-versionator_src_prepare

	DOCS="AUTHORS ChangeLog HACKING NEWS README"

	# Don't build BPM extension when not wanted
	if ! use bpm; then
		sed -i -e 's:Banshee.Bpm:$(NULL):g' src/Extensions/Makefile.am || die
	fi

	# Don't append -ggdb, bug #458632, upstream bug #698217
	sed -i -e 's:-ggdb3:$(NULL):g' libbanshee/Makefile.am || die
	sed -i -e 's:-ggdb3::g' src/Core/Banshee.WebBrowser/libossifer/Makefile.am || die

	AT_M4DIR="-I build/m4/banshee -I build/m4/shamrock -I build/m4/shave" \
	eautoreconf
}

src_configure() {
	# soundmenu needs a properly maintained and updated indicate-sharp
	local myconf="--disable-dependency-tracking
		--disable-static
		--disable-maintainer-mode
		--enable-gnome
		--enable-schemas-install
		--with-gconf-schema-file-dir=/etc/gconf/schemas
		--with-vendor-build-id=Gentoo/${PN}/${PVR}
		--disable-boo
		--disable-clutter
		--disable-gst-sharp
		--disable-torrent
		--disable-shave
		--enable-meego
		--disable-ubuntuone
		--enable-soundmenu
		--disable-upnp
		--disable-webkit"	## Upstream net-libs/webkit-gtk is an API mess with multiple vulnerabilities, disabled for now ##

	econf \
		$(use_enable doc docs) \
		$(use_enable doc user-help) \
		$(use_enable mtp) \
		$(use_enable daap) \
		$(use_enable ipod appledevice) \
		$(use_enable karma) \
		$(use_enable youtube) \
		$(use_enable udev gio) \
		$(use_enable udev gio_hardware) \
		${myconf}
}

src_compile() {
	emake MCS=/usr/bin/gmcs
}

src_install() {
	default
	prune_libtool_files --all
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mime_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mime_database_update
	gnome2_icon_cache_update
}
