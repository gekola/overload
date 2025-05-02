# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{11..13} )

DISTUTILS_USE_PEP517="setuptools"
inherit distutils-r1 pypi

MY_PV="${PV/_p/.post}"
MY_P="${PN}-${MY_PV}"
DESCRIPTION="Convert GeoJSON to WKT/WKB (Well-Known Text/Binary), and vice versa."
HOMEPAGE="https://github.com/geomet/geomet"

LICENSE="Apache-2.0"
SLOT=0
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/click[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"
