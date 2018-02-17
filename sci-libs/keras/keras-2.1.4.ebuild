# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{3,4,5,6} )

inherit distutils-r1 eutils

DESCRIPTION="Deep Learning for humans"
HOMEPAGE="https://www.keras.io
	https://github.com/keras-team/keras"
SRC_URI="https://github.com/keras-team/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=">=dev-python/numpy-1.9.1
	dev-python/pyyaml
	>=dev-python/six-1.9.0
	>=sci-libs/scipy-0.14
	sci-libs/tensorflow"
RDEPEND="${DEPEND}"
