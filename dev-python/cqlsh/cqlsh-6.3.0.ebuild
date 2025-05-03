# Copyright 2021-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

DISTUTILS_USE_PEP517=standalone
DISTUTILS_EXT=1
DISTUTILS_SINGLE_IMPL=1
inherit python-single-r1

DESCRIPTION="DataStax Python Driver for Apache Cassandra"
HOMEPAGE="https://github.com/datastax/python-driver"
CASS_VER="5.0.4"
SRC_URI="https://archive.apache.org/dist/cassandra/${CASS_VER}/apache-cassandra-${CASS_VER}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT=0
KEYWORDS="~amd64 ~x86"

BDEPEND="$(python_gen_cond_dep '
	dev-python/cython[${PYTHON_USEDEP}]
')"

RDEPEND="
$(python_gen_cond_dep '
	dev-python/cassandra-driver[${PYTHON_USEDEP}]
	dev-python/wcwidth[${PYTHON_USEDEP}]
')"

DEPEND="${RDEPEND}"

PATCHES="${FILESDIR}/cqlsh-fix-errno.patch"

S="${WORKDIR}/apache-cassandra-${CASS_VER}-src/pylib"

src_install() {
	python_domodule cqlshlib
	python_doscript "${FILESDIR}/cqlsh"
}
