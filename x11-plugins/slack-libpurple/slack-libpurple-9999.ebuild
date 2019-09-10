# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Slack module for libpurple"
HOMEPAGE="https://github.com/dylex/${PN}"
SRC_URI=""
EGIT_REPO_URI="${HOMEPAGE}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

DEPEND="
	net-im/pidgin
	dev-libs/openssl:0
	virtual/libc
"
RDEPEND="${DEPEND}"
