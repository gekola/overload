# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

MY_PN="Arduino-Makefile"

DESCRIPTION="Makefile for Arduino sketches."
HOMEPAGE="https://github.com/sudar/Arduino-Makefile"
SRC_URI="https://github.com/sudar/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

COMMONDEP="
dev-embedded/arduino
dev-python/pyserial"

RDEPEND="${COMMONDEP}
dev-embedded/avrdude"

DEPEND="${COMMONDEP}"

S="${WORKDIR}/${MY_PN}-${PV}"

src_unpack(){
	unpack ${A}
}

src_install(){
	dobin bin/ard-reset-arduino
	insinto /usr/share/arduino
	doins *.mk arduino-mk-vars.md
	if use doc; then
		dodoc HISTORY.md ard-reset-arduino.1 README.md
	fi
	if use examples; then
		insinto /usr/share/doc/"${P}"/
		doins -r examples
	fi
}
