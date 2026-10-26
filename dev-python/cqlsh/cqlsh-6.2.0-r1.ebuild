# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )

DISTUTILS_USE_PEP517=standalone
DISTUTILS_EXT=1
DISTUTILS_SINGLE_IMPL=1
inherit python-single-r1

CASS_VER="5.0.8"
DESCRIPTION="Command-line shell for Apache Cassandra"
HOMEPAGE="https://cassandra.apache.org/"
SRC_URI="https://archive.apache.org/dist/cassandra/${CASS_VER}/apache-cassandra-${CASS_VER}-src.tar.gz"
S="${WORKDIR}/apache-cassandra-${CASS_VER}-src/pylib"

LICENSE="Apache-2.0"
SLOT=0
KEYWORDS="~amd64 ~x86"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="$(python_gen_cond_dep '
	dev-python/cython[${PYTHON_USEDEP}]
')"

RDEPEND="
	${PYTHON_DEPS}
$(python_gen_cond_dep '
	dev-python/cassandra_driver[${PYTHON_USEDEP}]
	dev-python/wcwidth[${PYTHON_USEDEP}]
')"

DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}"/cqlsh-fix-errno.patch )

src_install() {
	python_domodule cqlshlib
	python_doscript "${FILESDIR}/cqlsh"
}
