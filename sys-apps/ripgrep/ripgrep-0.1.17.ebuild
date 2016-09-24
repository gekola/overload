# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="Ripgrep combines the usability of The Silver Searcher with the raw speed of grep"
HOMEPAGE="https://github.com/BurntSushi/ripgrep"
SRC_URI="https://github.com/BurntSushi/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Unlicense MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="virtual/rust:*"
DEPEND="${COMMON_DEPEND}
		dev-util/cargo"
RDEPEND="${DEPEND}"

src_compile() {
	cargo build --release
}

src_test() {
	cargo test
}

src_install() {
	dobin target/release/rg
	doman doc/rg.1
}
