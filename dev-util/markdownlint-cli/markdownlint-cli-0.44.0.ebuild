# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="MarkdownLint Command Line Interface"
HOMEPAGE="https://github.com/igorshubovych/markdownlint-cli"
SRC_URI="mirror://github.com/igorshubovych/${PN}/archive/refs/tags/v${PV}.tar.gz -> {P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

BDEPEND="net-libs/nodejs[npm]"
RDEPEND="net-libs/nodejs"

NPM_FLAGS=(
	--audit false
	--color false
	--foreground-scripts
	--global
	--offline
	--progress false
	--save false
	--verbose
)

src_compile() {
	npm "${NPM_FLAGS[@]}" pack || die
}

src_install() {
	npm "${NPM_FLAGS[@]}" \
		--prefix "${ED}"/usr \
		install \
		uglify-js-${PV}.tgz || die
}
