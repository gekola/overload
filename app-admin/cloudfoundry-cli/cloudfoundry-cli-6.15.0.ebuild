# Copyright 1999-2015 Nick Herman
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

SRC_URI="https://github.com/cloudfoundry/cli/archive/v${PV}.tar.gz -> ${P}.tar.gz"

inherit golang-vcs-snapshot golang-base

EGO_PN="github.com/cloudfoundry/cli/..."
EGO_SRC="github.com/cloudfoundry/cli"

DESCRIPTION="Command Line Interface for AWS Elastic Beanstalk."

HOMEPAGE="https://www.cloudfoundry.org/"
LICENSE="Apache-2.0"

SLOT="0"
KEYWORDS="~amd64"

DEPEND="${DEPEND}
		dev-go/go-bindata"

src_prepare() {
	sed -i -e '/go get/d' "src/${EGO_SRC}/bin/generate-language-resources"
}

src_compile() {
	cd "src/${EGO_SRC}"
	env GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)" "bin/build" || die
}

src_install() {
	dobin src/${EGO_SRC}/out/cf
}
