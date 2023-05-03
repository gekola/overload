# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9..11} )

inherit distutils-r1

MY_PV="${PV/_p/.post}"
MY_P="${PN}-${MY_PV}"
DESCRIPTION="Convert GeoJSON to WKT/WKB (Well-Known Text/Binary), and vice versa."
HOMEPAGE="https://github.com/geomet/geomet"
SRC_URI="mirror://pypi/${MY_P:0:1}/${PN}/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT=0
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

S="${WORKDIR}/${MY_P}"
