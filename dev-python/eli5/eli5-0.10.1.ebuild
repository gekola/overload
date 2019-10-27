# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

inherit distutils-r1

DESCRIPTION="A library for debugging machine learning classifiers"
HOMEPAGE="https://github.com/TeamHG-Memex/eli5"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT=0
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/numpy-1.9[${PYTHON_USEDEP}]
	sci-libs/scipy[${PYTHON_USEDEP}]
	>=sci-libs/scikits_learn-0.18[${PYTHON_USEDEP}]
	dev-python/attrs[${PYTHON_USEDEP}]
	dev-python/graphviz[${PYTHON_USEDEP}]
	dev-python/jinja[${PYTHON_USEDEP}]
	python_targets_python2_7? ( dev-python/singledispatch[python_targets_python2_7] )
"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"
