# Copyright 2021-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1

DESCRIPTION="DataStax Python Driver for Apache Cassandra"
HOMEPAGE="https://github.com/datastax/python-driver"
CASS_VER="4.1.1"
SRC_URI="https://archive.apache.org/dist/cassandra/${CASS_VER}/apache-cassandra-${CASS_VER}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT=0
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/cassandra-driver[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

PATCHES="${FILESDIR}/cqlsh-fix-errno.patch"

S="${WORKDIR}/apache-cassandra-${CASS_VER}-src/pylib"

src_install() {
	distutils-r1_src_install
	exeinto /usr/bin/
	doexe ../bin/cqlsh.py
	doexe ../bin/cqlsh
}
