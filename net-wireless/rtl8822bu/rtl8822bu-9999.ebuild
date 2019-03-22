# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-mod git-r3

DESCRIPTION="RTL8822BU Wireless Driver for Linux"
HOMEPAGE="https://github.com/EntropicEffect/rtl8822bu"
EGIT_REPO_URI="https://github.com/EntropicEffect/rtl8822bu.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

MODULE_NAMES="88x2bu(net/wireless:)"
BUILD_TARGETS="modules"
