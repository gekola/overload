# Copyrght 2014 Nick Herman
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit elisp git-2

DESCRIPTION="Search the word at point with Zeal."
HOMEPAGE="https://github.com/jinzhu/zeal-at-point"
EGIT_REPO_URI="git://github.com/jinzhu/${PN}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="dev-util/zeal"

SITEFILE="50${PN}-gentoo.el"
