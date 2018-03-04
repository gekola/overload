# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $

EAPI=6

inherit cmake-utils user check-reqs versionator flag-o-matic

DESCRIPTION="An OSS column-oriented database management system for real-time data analysis"
HOMEPAGE="https://clickhouse.yandex"
LICENSE="Apache-2.0"
MY_PN="ClickHouse"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/yandex/${MY_PN}.git"
	EGIT_SUBMODULES=( -private )
	SRC_URI=""
	TYPE="unstable"
else
	TYPE="stable"
	SRC_URI="https://github.com/yandex/${MY_PN}/archive/v${PV}-${TYPE}.tar.gz -> ${P}.tar.gz
https://github.com/google/cctz/archive/4f9776a.tar.gz -> cctz-4f9776a.tar.gz
!system-double-conversion? ( https://github.com/google/double-conversion/archive/cf2f0f3.tar.gz -> double-conversion-cf2f0f3.tar.gz )
!system-gtest? ( https://github.com/google/googletest/archive/d175c8b.tar.gz -> googletest-d175c8b.tar.gz )
!system-librdkafka? ( https://github.com/edenhill/librdkafka/archive/c3d50eb.tar.gz -> librdkafka-c3d50eb.tar.gz )
!system-lz4? ( https://github.com/lz4/lz4/archive/c10863b.tar.gz -> lz4-c10863b.tar.gz )
!system-re2? ( https://github.com/google/re2/archive/7cf8b88.tar.gz -> re2-7cf8b88.tar.gz )
!system-zookeeper? ( https://github.com/ClickHouse-Extras/zookeeper/archive/5aa9e88.tar.gz -> zookeeper-5aa9e88.tar.gz )
!system-zstd? ( https://github.com/facebook/zstd/archive/f4340f4.tar.gz -> zstd-f4340f4.tar.gz )"
	S="${WORKDIR}/${MY_PN}-${PV}-${TYPE}"
fi

SLOT="0/${TYPE}"
IUSE="+server +client mongodb static +system-double-conversion +system-gtest +system-librdkafka +system-lz4 +system-re2 +system-zookeeper +system-zstd cpu_flags_x86_sse4_2"
KEYWORDS="~amd64"

REQUIRED_USE="
	server? ( cpu_flags_x86_sse4_2 )
"

RDEPEND="system-lz4? ( app-arch/lz4 )
system-zstd? ( app-arch/zstd )
dev-libs/double-conversion
dev-libs/libltdl
system-librdkafka? ( dev-libs/librdkafka )
dev-libs/libpcre
client? (
	sys-libs/ncurses:0
	sys-libs/readline:0
)
|| (
	dev-db/unixODBC
	dev-libs/poco[odbc]
)
dev-libs/poco
sys-libs/zlib
"

DEPEND="${RDEPEND}
dev-cpp/gtest
dev-libs/icu
dev-libs/glib
dev-libs/boost
dev-libs/openssl
dev-libs/zookeeper-c
dev-util/patchelf
sys-libs/libtermcap-compat
virtual/libmysqlclient
|| ( >=sys-devel/gcc-7.0 >=sys-devel/clang-5.0 )"

pkg_pretend() {
	CHECKREQS_DISK_BUILD="2G"
	# Actually it is 960M on my machine
	check-reqs_pkg_pretend
	if [[ $(tc-getCC) == clang ]]; then
		:
	elif [[ $(gcc-major-version) -lt 7 ]]; then
		eerror "Compilation with gcc older than 7.0 is not supported"
		die "Too old gcc found."
	fi
}

src_unpack() {
	default_src_unpack
	[[ ${PV} == 9999 ]] && return 0
	cd "${S}/contrib"
	mkdir -p cctz double-conversion googletest librdkafka lz4 re2 zookeeper zstd
	tar --strip-components=1 -C cctz -xf "${DISTDIR}/cctz-4f9776a.tar.gz"
	use system-double-conversion || tar --strip-components=1 -C double-conversion -xf "${DISTDIR}/double-conversion-cf2f0f3.tar.gz"
	use system-gtest || tar --strip-components=1 -C googletest -xf "${DISTDIR}/googletest-d175c8b.tar.gz"
	use system-librdkafka || tar --strip-components=1 -C librdkafka -xf "${DISTDIR}/librdkafka-3401fa1.tar.gz"
	use system-lz4 || tar --strip-components=1 -C lz4 -xf "${DISTDIR}/lz4-c10863b.tar.gz"
	use system-re2 || tar --strip-components=1 -C re2 -xf "${DISTDIR}/re2-7cf8b88.tar.gz"
	use system-zookeeper || tar --strip-components=1 -C zookeeper -xf "${DISTDIR}/zookeeper-d2f05a6.tar.gz"
	use system-zstd || tar --strip-components=1 -C zstd -xf "${DISTDIR}/zstd-f4340f4.tar.gz"
}

src_prepare() {
	default_src_prepare
	#sed -i -r -e "s: -Wno-(for-loop-analysis|unused-local-typedef|unused-private-field): -Wno-unused-variable:g" \
	#	contrib/libpoco/CMakeLists.txt || die "Cannot patch poco"
	if $(tc-getCC) -no-pie -v 2>&1 | grep -q unrecognized; then
		sed -i -e 's:--no-pie::' -i CMakeLists.txt || die "Cannot patch CMakeLists.txt"
		sed -i -e 's:-no-pie::' -i CMakeLists.txt || die "Cannot patch CMakeLists.txt"
	else
		sed -i -e 's:--no-pie:-no-pie:' -i CMakeLists.txt || die "Cannot patch CMakeLists.txt"
	fi

	sed -i -- "s/VERSION_REVISION .*)/VERSION_REVISION ${PV##*.})/g" libs/libcommon/cmake/version.cmake
	sed -i -- "s/VERSION_DESCRIBE .*)/VERSION_DESCRIBE v${PV}-${TYPE})/g" libs/libcommon/cmake/version.cmake
}

src_configure() {
	append-cxxflags $(test-flags-CXX -Wno-error=unused-parameter)
	DISABLE_MONGODB=1
	use mongodb && DISABLE_MONGODB=0
	export DISABLE_MONGODB
	local mycmakeargs=(
		-DUSE_INTERNAL_DOUBLE_CONVERSION_LIBRARY=$(usex system-double-conversion 0 1)
		-DUSE_INTERNAL_GTEST_LIBRARY=$(usex system-gtest 0 1)
		-DUSE_INTERNAL_RDKAFKA_LIBRARY=$(usex system-librdkafka 0 1)
		-DUSE_INTERNAL_LZ4_LIBRARY=$(usex system-lz4 0 1)
		-DUSE_INTERNAL_RE2_LIBRARY=$(usex system-re2 0 1)
		-DUSE_INTERNAL_ZOOKEEPER_LIBRARY=$(usex system-zookeeper 0 1)
		-DUSE_INTERNAL_ZSTD_LIBRARY=$(usex system-zstd 0 1)
		-DUSE_INTERNAL_BOOST_LIBRARY=0
		-DUSE_INTERNAL_ZLIB_LIBRARY=0
		-DUSE_STATIC_LIBRARIES=$(usex static)
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile clickhouse
}

src_install() {
	cd "${BUILD_DIR}"
	einfo $(pwd)
	patchelf --remove-rpath dbms/src/Server/clickhouse
	
	dolib.so dbms/libclickhouse.so.${PV}
	dosym libclickhouse.so.${PV} /usr/$(get_libdir)/libclickhouse.so.1
	dosym libclickhouse.so.${PV} /usr/$(get_libdir)/libclickhouse.so

	if use server; then
		exeinto /usr/sbin
		newexe dbms/src/Server/clickhouse clickhouse-server
		newinitd "${FILESDIR}"/clickhouse-server.initd clickhouse

		insinto /etc/clickhouse-server
		doins "${S}"/dbms/src/Server/config.xml
		doins "${S}"/dbms/src/Server/users.xml

		sed -e 's:/opt/clickhouse:/var/lib/clickhouse:g' -i "${ED}/etc/clickhouse-server/config.xml"
		sed -e '/listen_host/s%::<%::1<%' -i "${ED}/etc/clickhouse-server/config.xml"

		dodir /var/lib/clickhouse/data/default /var/lib/clickhouse/metadata/default /var/lib/clickhouse/tmp
		dodir /var/log/clickhouse-server
		fowners -R clickhouse:clickhouse /var/lib/clickhouse
		fperms -R 0750 /var/lib/clickhouse
		fowners -R clickhouse:adm /var/log/clickhouse-server
		fperms -R 0750 /var/log/clickhouse-server
	fi

	if use client; then
		exeinto /usr/bin
		newexe dbms/src/Server/clickhouse clickhouse-client

		insinto /etc/clickhouse-client
		newins "${S}"/dbms/src/Server/clickhouse-client.xml config.xml
	fi
}

pkg_setup() {
	if use server; then
		enewgroup clickhouse
		enewuser clickhouse -1 -1 /var/lib/clickhouse clickhouse
	fi
}
