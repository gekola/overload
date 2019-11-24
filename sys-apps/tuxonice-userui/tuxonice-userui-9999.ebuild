# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit eutils toolchain-funcs git-r3

DESCRIPTION="User Interface for TuxOnIce"
HOMEPAGE="https://gitlab.com/nigelcunningham/Tuxonice-Userui"
EGIT_REPO_URI="https://gitlab.com/nigelcunningham/Tuxonice-Userui.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="fbsplash"

DEPEND="fbsplash? (
		media-libs/freetype:2=
		media-libs/libmng:0=
		media-libs/libpng:0=
		virtual/jpeg:0=
	)"
RDEPEND="${DEPEND}"

src_prepare() {
	local d=${WORKDIR}/debian/patches
	sed -i -e 's/make/$(MAKE)/' Makefile || die
	sed -i -e 's/ -O3//' Makefile fbsplash/Makefile usplash/Makefile || die

	default
}

src_compile() {
	use fbsplash && export USE_FBSPLASH=1
	emake CC="$(tc-getCC)" tuxoniceui
}

src_install() {
	into /
	dosbin tuxoniceui
	dodoc AUTHORS ChangeLog KERNEL_API README TODO USERUI_API
}

pkg_postinst() {
	if use fbsplash; then
		einfo
		elog "You must create a symlink from /etc/splash/tuxonice"
		elog "to the theme you want tuxonice to use, e.g.:"
		elog
		elog "  # ln -sfn /etc/splash/emergence /etc/splash/tuxonice"
	fi
	einfo
	einfo "Please see /usr/share/doc/${PF}/README.* for further"
	einfo "instructions."
	einfo
}
