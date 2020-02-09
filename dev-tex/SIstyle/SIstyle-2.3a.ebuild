# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit latex-package

DESCRIPTION="LaTeX package to typeset SI units, numbers and angles."
HOMEPAGE="http://www.ctan.org/tex-archive/macros/latex/contrib/SIstyle/"
SRC_URI="http://mirrors.ctan.org/macros/latex/contrib/${PN}.zip"

LICENSE="LPPL-1.3b"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=""

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}/figs"
	unpack ./graphs_scr.zip
}

src_install() {
	latex-package_src_install
	latex-package_src_install

	insinto "${TEXMF}/SIstyle"
	doins sistyle.dtx sistyle.ins figs/fig{1,2}.*ps || die
	cd "${S}/figs/graphs_scr"
	insinto "${TEXMF}/SIstyle/graphs_src"
	doins *.mp MPfig.bat readme_figs.txt *.m || die
}
