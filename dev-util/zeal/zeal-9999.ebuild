# Copyrght 2014 Nick Herman
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit git-2 qmake-utils

DESCRIPTION="Zeal is a simple offline API documentation browser inspired by Dash (OS X app), available for Linux and Windows."
HMEPAGE="http://zealdocs.org/"
EGIT_REPO_URI="git://github.com/jkozera/${PN}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="emacs"

DEPEND="
		dev-qt/qtconcurrent:5
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtsql:5[sqlite]
		dev-qt/qtwebkit:5[widgets]
		dev-qt/qtxml:5
		x11-libs/xcb-util-keysyms
"
PDEPEND="emacs? ( app-emacs/zeal-at-point )"

DOCS="README.md"

src_prepare() {
	epatch "${FILESDIR}/${PN}-quazip-gentoo-fix.patch"
	epatch "${FILESDIR}/${PN}-nounity.patch"
}

src_configure() {
	cd zeal
	eqmake5
}

src_compile() {
	cd zeal
	emake || die 'make failed'
}

src_install() {
	exeinto /usr/bin
	doexe zeal/zeal

	insinto /usr/share/pixmaps/zeal
	doins zeal/icons/*.png

	insinto /usr/share/applications
	doins zeal/zeal.desktop
}
