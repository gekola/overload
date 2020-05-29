# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DB_VER="4.8"

LANGS="af af_ZA ar be_BY bg bg_BG ca ca_ES ca@valencia cs cy da de el el_GR en en_GB eo es es_AR es_CL es_CO es_DO es_ES es_MX es_UY es_VE et et_EE eu_ES fa fa_IR fi fr fr_CA fr_FR gl he hi_IN hr hu id_ID it it_IT ja ka kk_KZ ko_KR ku_IQ ky la lt lv_LV mk_MK mn ms_MY nb ne nl pam pl pt_BR pt_PT ro ro_RO ru ru_RU sk sl_SI sq sr sr@latin sv ta th_TH tr tr_TR uk ur_PK uz@Cyrl vi vi_VN zh zh_CN zh_HK zh_TW"

inherit autotools db-use eutils desktop xdg-utils

MyPV="${PV/_/-}"
MyPN="litecoin"
MyP="${MyPN}-${MyPV}"

DESCRIPTION="P2P Internet currency based on Bitcoin but easier to mine"
HOMEPAGE="https://litecoin.org/"
SRC_URI="https://github.com/${MyPN}-project/${MyPN}/archive/v${MyPV}.tar.gz -> ${MyP}.tar.gz"

LICENSE="MIT ISC GPL-3 LGPL-2.1 public-domain || ( CC-BY-SA-3.0 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dbus kde +qrcode upnp"
for l in $LANGS; do
	IUSE+=" l10n_$l"
done

RDEPEND="
	dev-libs/boost:=[threads(+)]
	dev-libs/openssl:0[-bindist]
	dev-libs/protobuf:=
	qrcode? (
		media-gfx/qrencode
	)
	upnp? (
		net-libs/miniupnpc
	)
	sys-libs/db:$(db_ver_to_slot "${DB_VER}")[cxx]
	>=dev-libs/leveldb-1.18-r1
	dev-qt/qtnetwork:5[ssl]
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dbus? (
		dev-qt/qtdbus:5
	)
"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5
	>=app-shells/bash-4.1
"

PATCHES=(
	"${FILESDIR}"/0.9.0-sys_leveldb.patch
	"${FILESDIR}"/fix-includes.patch
	"${FILESDIR}"/litecoind-0.13.2.1-memenv_h.patch
	"${FILESDIR}"/litecoin-boost-1.73.patch
)

DOCS="doc/README.md doc/release-notes-litecoin.md"

S="${WORKDIR}/${MyP}"

src_prepare() {
	default

	eautoreconf
	rm -r src/leveldb

	cd src || die

	local filt= yeslang= nolang=

	for lan in $LANGS; do
		if [ ! -e qt/locale/bitcoin_$lan.ts ]; then
			ewarn "Language '$lan' no longer supported. Ebuild needs update."
		fi
	done

	for ts in $(ls qt/locale/*.ts)
	do
		x="${ts/*bitcoin_/}"
		x="${x/.ts/}"
		if ! use "l10n_$x"; then
			nolang="$nolang $x"
			#rm "$ts"
			filt="$filt\\|$x"
		else
			yeslang="$yeslang $x"
		fi
	done

	filt="bitcoin_\\(${filt:2}\\)\\.\(qm\|ts\)"
	sed "/${filt}/d" -i 'qt/bitcoin_locale.qrc'
	einfo "Languages -- Enabled:$yeslang -- Disabled:$nolang"
}

src_configure() {
	local my_econf=
	if use upnp; then
		my_econf="${my_econf} --with-miniupnpc --enable-upnp-default"
	else
		my_econf="${my_econf} --without-miniupnpc --disable-upnp-default"
	fi
	econf \
		--enable-wallet \
		--disable-ccache \
		--disable-static \
		--disable-tests \
		--disable-bench \
		--with-system-leveldb \
		--with-system-libsecp256k1  \
		--without-libs \
		--without-utils \
		--without-daemon  \
		--with-gui=qt5 \
		$(use_with dbus qtdbus)  \
		$(use_with qrcode qrencode)  \
		${my_econf}
}

src_install() {
	default

	insinto /usr/share/pixmaps
	newins "share/pixmaps/bitcoin.ico" "${PN}.ico"

	make_desktop_entry "${PN} %u" "Litecoin-Qt" "/usr/share/pixmaps/${PN}.ico" "Qt;Network;P2P;Office;Finance;" "MimeType=x-scheme-handler/litecoin;\nTerminal=false"

	newman doc/man/litecoin-qt.1 ${PN}.1

	if use kde; then
		insinto /usr/share/kde4/services
		newins contrib/debian/bitcoin-qt.protocol ${PN}.protocol
	fi
}

update_caches() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postinst() {
	update_caches
}

pkg_postrm() {
	update_caches
}
