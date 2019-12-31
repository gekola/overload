# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DB_VER="4.8"

inherit autotools db-use eutils systemd

MyPV="${PV/_/-}"
MyPN="litecoin"
MyP="${MyPN}-${MyPV}"

DESCRIPTION="P2P Internet currency based on Bitcoin but easier to mine"
HOMEPAGE="https://litecoin.org/"
SRC_URI="https://github.com/${MyPN}-project/${MyPN}/archive/v${MyPV}.tar.gz -> ${MyP}.tar.gz"

LICENSE="MIT ISC GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="logrotate upnp +wallet"

RDEPEND="
	acct-group/litecoin
	acct-user/litecoin
	dev-libs/boost[threads(+)]
	dev-libs/openssl:0[-bindist]
	logrotate? ( app-admin/logrotate )
	upnp? ( net-libs/miniupnpc )
	sys-libs/db:$(db_ver_to_slot "${DB_VER}")[cxx]
	virtual/bitcoin-leveldb
"
DEPEND="${RDEPEND}
	>=app-shells/bash-4.1
	sys-apps/sed
"

PATCHES=(
	"${FILESDIR}/0.9.0-sys_leveldb.patch"
	"${FILESDIR}/fix-includes.patch"
	"${FILESDIR}/litecoind-0.13.2.1-memenv_h.patch"
)

S="${WORKDIR}/${MyP}"

src_prepare() {
	default

	eautoreconf
	rm -r src/leveldb
}

src_configure() {
	local my_econf=
	if use upnp; then
		my_econf="${my_econf} --with-miniupnpc --enable-upnp-default"
	else
		my_econf="${my_econf} --without-miniupnpc --disable-upnp-default"
	fi
	econf \
		$(use_enable wallet)\
		--disable-ccache \
		--disable-static \
		--disable-tests \
		--disable-bench \
		--with-system-leveldb \
		--with-system-libsecp256k1  \
		--without-libs \
		--with-daemon  \
		--without-gui     \
		--without-qrencode \
		${my_econf}
}

src_install() {
	default

	insinto /etc/litecoin
	doins "${FILESDIR}/litecoin.conf"
	fowners litecoin:litecoin /etc/litecoin/litecoin.conf
	fperms 600 /etc/litecoin/litecoin.conf

	newconfd "${FILESDIR}/litecoin.confd" ${PN}
	newinitd "${FILESDIR}/litecoin.initd-r1" ${PN}
	systemd_dounit "${FILESDIR}/litecoin.service"

	keepdir /var/lib/litecoin/.litecoin
	fperms 700 /var/lib/litecoin
	fowners litecoin:litecoin /var/lib/litecoin/
	fowners litecoin:litecoin /var/lib/litecoin/.litecoin
	dosym /etc/litecoin/litecoin.conf /var/lib/litecoin/.litecoin/litecoin.conf

	dodoc doc/README.md
	newman doc/man/litecoind.1 litecoind.1

	if use logrotate; then
		insinto /etc/logrotate.d
		newins "${FILESDIR}/litecoind.logrotate" litecoind
	fi
}
