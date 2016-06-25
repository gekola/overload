# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="CAPT driver for some Canon (and other) printers"
HOMEPAGE="https://github.com/agalakhov/captdriver"
EGIT_REPO_URI="https://github.com/agalakhov/captdriver.git"

inherit autotools git-r3

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="static-libs"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	exeinto /usr/libexec/cups/filter
	doexe src/rastertocapt
	insinto /usr/share/ppd
	doins Canon-LBP-2900.ppd
}
