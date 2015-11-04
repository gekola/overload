# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3,3_4} )

SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

inherit distutils-r1

DESCRIPTION="Utility library for gitignore style pattern matching of file paths."

HOMEPAGE="https://github.com/cpburnz/python-path-specification"
LICENSE="MPL-2.0"

SLOT="0"
KEYWORDS="~amd64"
