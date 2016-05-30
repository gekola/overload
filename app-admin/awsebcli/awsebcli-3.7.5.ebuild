# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python{2_7,3_4} )

SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

inherit distutils-r1

DESCRIPTION="Command Line Interface for AWS Elastic Beanstalk."

HOMEPAGE="http://aws.amazon.com/elasticbeanstalk/"
LICENSE="Apache-2.0"

SLOT="0"
KEYWORDS="~amd64"

DEPEND="
		>=dev-python/pyyaml-3.11
		>=dev-python/botocore-1.0.1
		>=dev-python/cement-2.4
		~dev-python/colorama-0.3.3
		>=dev-python/blessed-1.9.5
		>=dev-python/pathspec-0.3.3
		=dev-python/docopt-0.6*
		>=dev-python/requests-2.6.1
		=dev-python/texttable-0.8*
		>=dev-python/websocket-client-0.11.0
		!>=dev-python/websocket-client-1.0
		=dev-python/docker-py-1.1*
		=dev-python/dockerpty-0.3*
		>=dev-python/sematic_version-2.4.0
"

src_prepare() {
	epatch "${FILESDIR}/${PN}-fix-bash-completions.patch"
}
