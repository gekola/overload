# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit golang-vcs-snapshot golang-build

EGO_PN="github.com/jteeuwen/go-bindata/..."
EGO_SRC="github.com/jteeuwen/go-bindata"

DESCRIPTION="A small utility which generates Go code from any file"
HOMEPAGE="https://github.com/jteeuwen/go-bindata"
SRC_URI="https://github.com/jteeuwen/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND=""

RDEPEND="${DEPEND}"

src_install() {
	rm -rf src/github.com/jteeuwen/go-bindata/testdata
	golang-build_src_install
	exeinto "$(go env GOROOT)/bin"
	doexe bin/go-bindata
	dosym "../..$(go env GOROOT)/bin/go-bindata" /usr/bin/go-bindata
}
