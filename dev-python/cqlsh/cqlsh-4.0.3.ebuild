# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1

DESCRIPTION="DataStax Python Driver for Apache Cassandra"
HOMEPAGE="https://github.com/datastax/python-driver"
SRC_URI="https://archive.apache.org/dist/cassandra/${PV}/apache-cassandra-${PV}-src.tar.gz"

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

S="${WORKDIR}/apache-cassandra-${PV}-src/pylib"

src_install() {
	distutils-r1_src_install
	exeinto /usr/bin/
	doexe ../bin/cqlsh.py
	doexe ../bin/cqlsh
}
