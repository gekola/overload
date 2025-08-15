# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION=" runcat module for polybar (or waybar) written in C++ "
HOMEPAGE="https://github.com/2IMT/polycat"
SRC_URI="https://github.com/2IMT/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND=""

src_compile() {
	emake PREFIX="${EPREFIX}/usr" || die "emake failed"
}

src_install() {
	emake DEST_DIR="${D}" PREFIX="${EPREFIX}/usr" install
}
