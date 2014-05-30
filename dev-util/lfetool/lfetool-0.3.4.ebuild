# Copyrght 2014 Nick Herman
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit bash-completion-r1

DESCRIPTION="An Erlang Lisper's Tool for Admin Tasks, Project Creation, and Infrastructure."
HMEPAGE="https://github.com/lfe/lfetool"
SRC_URI="https://github.com/lfe/${PN}/archive/${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="bash-completion"

DEPEND=">=dev-lang/lfe-0.8"

src_compile() {
	make build
	./lfetool -x
}

src_install() {
	exeinto /usr/bin
	doexe lfetool

	if use bash-completion ; then
		newbashcomp bash-complete lfetool
	fi
}
