# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit eutils cmake-utils

DESCRIPTION="A Fuzzy Logic Control Library in C++"
HOMEPAGE="http://www.fuzzylite.com/"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="no-c++11 static-libs"

DEPEND=""
RDEPEND="
	${DEPEND}
"

S="${WORKDIR}/${P}/${PN}"

src_configure() {
    local mycmakeargs=(
		-DFL_BUILD_STATIC="$(usex static-libs)"
		-DFL_USE_FLOAT=ON
		-DFL_BACKTRACE="ON"
		-DFL_CPP11="$(usex !no-c++11)"
	)

	cmake-utils_src_configure
}

#src_install() {
#    cmake-utils_src_install
#}

#pkg_postinst() {
#    games_pkg_postinst
#
#	elog For the game to work properly, please copy your 
#	elog \"Heroes Of Might and Magic: The Wake  Of Gods\" 
#	elog game directory into ${GAMES_DATADIR}/${PN} .
#	elog For more information, please visit:
#	elog http://wiki.vcmi.eu/index.php?title=Installation_on_Linux
#}
