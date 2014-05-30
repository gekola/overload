# Copyright 2014 Nick Herman
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit multilib elisp

DESCRIPTION="Lisp-flavoured Erlang"
HMEPAGE="http://lfe.github.io/"
SRC_URI="https://github.com/rvirding/${PN}/archive/v${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="emacs"

RDEPEND="dev-lang/erlang"
DEPEND="${RDEPEND}"

SITEFILE=50${PN}-gentoo.el

src_compile() {
	make compile ERL_LIBS="${D}/usr/$(get_libdir)/erlang/lib/"

	if use emacs ; then
		pushd emacs
		elisp-compile *.el
		popd
	fi
}

src_install() {
	exeinto /usr/$(get_libdir)/erlang/lib/${PN}/bin
	doexe bin/*

	for dir in ebin include ; do
		insinto /usr/$(get_libdir)/erlang/lib/${PN}/$dir
		doins $dir/*
	done

	if use emacs ; then
		elisp-install ${PN} emacs/*.{el,elc}
		elisp-site-file-install "${FILESDIR}"/${SITEFILE}
	fi

	for ex in $(ls bin) ; do
		dosym /usr/$(get_libdir)/erlang/lib/${PN}/bin/$ex /usr/bin/$ex
	done
}
