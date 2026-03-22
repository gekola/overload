# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="An OSS column-oriented database management system for real-time data analysis"
HOMEPAGE="https://clickhouse.tech/"
TYPE="lts"
SRC_URI="
	amd64? (
		https://packages.clickhouse.com/tgz/${TYPE}/clickhouse-common-static-${PV}-amd64.tgz
		client? ( https://packages.clickhouse.com/tgz/${TYPE}/clickhouse-client-${PV}-amd64.tgz )
		server? ( https://packages.clickhouse.com/tgz/${TYPE}/clickhouse-server-${PV}-amd64.tgz )
	)
	arm64? (
		https://packages.clickhouse.com/tgz/${TYPE}/clickhouse-common-static-${PV}-arm64.tgz
		client? ( https://packages.clickhouse.com/tgz/${TYPE}/clickhouse-client-${PV}-arm64.tgz )
		server? ( https://packages.clickhouse.com/tgz/${TYPE}/clickhouse-server-${PV}-arm64.tgz )
	)
"

S="${WORKDIR}/clickhouse-common-static-${PV}"

LICENSE="Apache-2.0"
SLOT="0/${TYPE}"
KEYWORDS="~amd64 ~arm64"
IUSE="+client doc +server"

DEPEND="
	server? (
			acct-group/clickhouse
			acct-user/clickhouse
	)
"
RDEPEND="${DEPEND}
	server? ( sys-libs/libcap )
"

src_install() {
	cp -r usr "${D}/"
	use client && cp -r "../clickhouse-client-${PV}/etc" "../clickhouse-client-${PV}/usr" "${D}/"
	if use server; then
		cp -r "../clickhouse-server-${PV}/etc" "../clickhouse-server-${PV}/usr" "${D}/"
		rm -rf "${D}/etc/init.d"

		newinitd "${FILESDIR}"/clickhouse-server.initd clickhouse-server
		systemd_dounit "../clickhouse-server-${PV}/lib/systemd/system/clickhouse-server.service"

		sed -e 's:/opt/clickhouse:/var/lib/clickhouse:g' -i "${ED}/etc/clickhouse-server/config.xml"
		sed -e '/listen_host/s%::<%::1<%' -i "${ED}/etc/clickhouse-server/config.xml"

		keepdir /var/lib/clickhouse/data/default /var/lib/clickhouse/metadata/default /var/lib/clickhouse/tmp
		keepdir /var/log/clickhouse-server
		fowners -R clickhouse:clickhouse /var/lib/clickhouse
		fperms -R 0750 /var/lib/clickhouse
		fowners -R clickhouse:adm /var/log/clickhouse-server
		fperms -R 0750 /var/log/clickhouse-server
	fi
	rm -rf "${D}/usr/share/doc/clickhouse-client" "${D}/usr/share/doc/clickhouse-server"
	mv "${D}/usr/share/doc/clickhouse-common-static" "${D}/usr/share/doc/clickhouse"
	if ! use doc; then
		rm -rf "${D}/usr/share/doc/clickhouse"
	fi
}
