# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit qmake-utils xdg-utils desktop

DESCRIPTION="Call graph viewer for callgrind"
HOMEPAGE="https://kde.org/applications/development/kcachegrind"

BUNDLENAME=kcachegrind
SRC_URI="https://download.kde.org/stable/release-service/${PV}/src/${BUNDLENAME}-${PV}.tar.xz"
S="${WORKDIR}/${BUNDLENAME}-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug tools"

DEPEND="
dev-qt/qtbase:6=[gui,widgets]
"
RDEPEND="${DEPEND}"

src_configure() {
	eqmake6
}

src_install() {
	exeinto /usr/bin/
	doexe cgview/cgview
	doexe qcachegrind/qcachegrind
	if use tools ; then
		# TODO: add hotshot tool cmake processing (under use)
		doexe converters/{dprof,memprof,op,pprof}2calltree
	fi

	domenu qcachegrind/qcachegrind.desktop

	for px in 32 48 64 128 ; do
		insinto /usr/share/icons/hicolor/${px}x${px}/apps/
		newins kcachegrind/${px}-apps-kcachegrind.png kcachegrind.png
	done
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
