# Copyright 2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs systemd

DESCRIPTION="Advanced MySQL Proxy"
HOMEPAGE="http://www.proxysql.com/"
SRC_URI="https://github.com/sysown/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/openssl:0="
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
		sed -i -e 's~usr/local~usr~' "${S}/systemd/${PN}.service" || die
		default
}

src_configure() {
	tc-export CC CPP CXX LD AR
}

src_install() {
	exeinto /usr/bin
	doexe src/proxysql
	insinto /etc
	doins etc/proxysql.cnf
	fperms 0600 /etc/proxysql.cnf
	keepdir /var/lib/proxysql
	systemd_dounit systemd/proxysql.service
	newinitd "${FILESDIR}/${PN}.init" ${PN}
	newconfd "${FILESDIR}/${PN}.conf" ${PN}
}
