# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

DISTUTILS_USE_PEP517="setuptools"
PYPI_NO_NORMALIZE=1
inherit distutils-r1 pypi

DESCRIPTION="DataStax Python Driver for Apache Cassandra"
HOMEPAGE="https://github.com/datastax/python-driver"

LICENSE="Apache-2.0"
SLOT=0
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-libs/libev
	dev-python/cython[${PYTHON_USEDEP}]
	<dev-python/geomet-0.3[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/0006-relax_vesioned_cython_dependency.patch"
	"${FILESDIR}/remove-obsolete-code-to-fix-libevwrapper.patch"
)
