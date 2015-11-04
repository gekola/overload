# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3,3_4} )

SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

inherit distutils-r1

DESCRIPTION=" A thin, practical wrapper around terminal styling, screen positioning, and keyboard input."

HOMEPAGE="https://github.com/jquast/blessed"
LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64"

DEPEND="
		>=dev-python/wcwidth-0.1.4
		>=dev-python/six-1.9.0
"
