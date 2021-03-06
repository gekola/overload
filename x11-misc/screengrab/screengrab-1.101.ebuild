# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils xdg-utils

DESCRIPTION="Qt application for getting screenshots"
HOMEPAGE="https://lxqt.org/"
SRC_URI="https://downloads.lxqt.org/downloads/${PN}/${PV}/${P}.tar.xz"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 x86"
IUSE="+edit +kwindowsystem +upload"
PATCHES=(
	"${FILESDIR}/${PN}-optional-kwindowsystem.patch"
	"${FILESDIR}/${PN}-fix-no-upload.patch"
)

BDEPEND="dev-qt/linguist-tools:5"
DEPEND="
	edit? ( >=dev-libs/libqtxdg-3.3.1 )
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	upload? ( dev-qt/qtnetwork:5 )
	kwindowsystem? ( kde-frameworks/kwindowsystem:5[X] )
	x11-libs/libxcb
	x11-libs/libX11
"
RDEPEND="${DEPEND}"

src_configure() {
		local mycmakeargs=(
			-DSG_EXT_EDIT="$(usex edit)"
			-DSG_EXT_UPLOADS="$(usex upload)"
			-DSG_USE_SYSTEM_KF5="$(usex kwindowsystem)"
		)

		cmake-utils_src_configure
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
