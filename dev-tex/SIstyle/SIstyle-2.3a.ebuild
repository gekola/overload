# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit latex-package

DESCRIPTION="LaTeX package to typeset SI units, numbers and angles"
HOMEPAGE="https://ctan.org/pkg/sistyle"
SRC_URI="https://mirrors.ctan.org/macros/latex/contrib/sistyle.zip -> ${P}.zip"
S="${WORKDIR}/${PN}"

LICENSE="LPPL-1.3b"
SLOT="0"
KEYWORDS="~amd64 ~x86"

BDEPEND="app-arch/unzip"

# The documentation ships prebuilt as SIstyle-2.3a.pdf.
LATEX_PACKAGE_SKIP="sistyle.dtx"

src_unpack() {
	unpack ${A}
	cd "${S}/figs"
	unpack ./graphs_scr.zip
}

src_install() {
	latex-package_src_install

	insinto "${TEXMF}/SIstyle"
	doins sistyle.dtx sistyle.ins figs/fig{1,2}.*ps || die
	cd "${S}/figs/graphs_scr"
	insinto "${TEXMF}/SIstyle/graphs_src"
	doins *.mp MPfig.bat readme_figs.txt *.m || die
}
