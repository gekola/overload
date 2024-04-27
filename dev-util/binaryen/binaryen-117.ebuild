# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION=""
HOMEPAGE="https://github.com/WebAssembly/binaryen"
SRC_URI="https://github.com/WebAssembly/${PN}/archive/version_${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-version_${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"
PATCHES=(
	"${FILESDIR}/fix-gcc-binaryen-117.patch"
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=OFF
	)

	cmake_src_configure
}
