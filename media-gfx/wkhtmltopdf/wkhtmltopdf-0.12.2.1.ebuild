# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit qt4-r2 multilib eutils

DESCRIPTION="Convert html to pdf (and various image formats) using webkit"
HOMEPAGE="http://wkhtmltopdf.org/ https://github.com/wkhtmltopdf/wkhtmltopdf/"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz https://github.com/${PN}/qt/tarball/7e48a1fac7e0f9aefccd01e9871f987da3a62fda -> wkhtmltopdf-qt-v4.8.7.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples icu"

RDEPEND="dev-libs/libxml2[icu=]
		>=sys-libs/zlib-1.2.8-r1
        dev-libs/icu
		>=dev-libs/openssl-1.0.1h-r2:0"
DEPEND="${RDEPEND}"

src_unpack() {
  unpack "${P}.tar.gz" || die
  unpack "wkhtmltopdf-qt-v4.8.7.tar.gz"
  rm -rf "${S}/qt"
  mv wkhtmltopdf-qt-* "${S}/qt"
}

src_prepare() {
	# fix install paths and don't precompress man pages
	epatch "${FILESDIR}"/${PN}-0.12.1.2-manpages.patch

	sed -i "s:\(INSTALLBASE/\)lib:\1$(get_libdir):" src/lib/lib.pro || die
	if use icu; then
		sed -i -e '/CONFIG\s*+=\s*text_breaking_with_icu/ s:^#\s*::' \
			qt/src/3rdparty/webkit/Source/JavaScriptCore/JavaScriptCore.pri
	fi
}

src_configure() {
	cd ${S}/qt
	./configure -opensource -confirm-license -fast -release -static -graphicssystem raster $(use !icu && echo -ne '-no')-icu -webkit -exceptions -xmlpatterns -system-zlib -system-libpng -system-libjpeg -no-libmng -no-libtiff -no-accessibility -no-stl -no-qt3support -no-phonon -no-phonon-backend -no-opengl -no-declarative -no-script -no-scripttools -no-sql-ibase -no-sql-mysql -no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-multimedia -nomake demos -nomake docs -nomake examples -nomake tools -nomake tests -nomake translations -silent -xrender -largefile -iconv -openssl -no-javascript-jit -no-rpath -no-dbus -no-nis -no-cups -no-pch -no-gtkstyle -no-nas-sound -no-sm -no-xshape -no-xinerama -no-xcursor -no-xfixes -no-xrandr -no-mitshm -no-xinput -no-xkb -no-glib -no-gstreamer -no-openvg -no-xsync -no-audio-backend --prefix=${S}/qt
}

src_compile() {
	cd ${S}/qt
	make || die
	cd "${S}"
	qt/bin/qmake INSTALLBASE=/usr
}

src_install() {
    cd "${S}"
	emake INSTALL_ROOT="${D}" install
	dodoc AUTHORS CHANGELOG* README.md
	use examples && dodoc -r examples
}
