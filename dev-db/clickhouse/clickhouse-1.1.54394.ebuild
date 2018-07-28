# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $

EAPI=6

CMAKE_MAKEFILE_GENERATOR="ninja"

inherit cmake-utils user check-reqs versionator flag-o-matic systemd

declare -A contrib_versions=(
	["capnproto"]="7173ab6"
	["cctz"]="4f9776a"
	["double-conversion"]="cf2f0f3"
	["googletest"]="d175c8b"
	["librdkafka"]="7478b5e"
	["lz4"]="c10863b"
	["poco"]="3a2d0a8"
	["re2"]="7cf8b88"
	["ssl"]="6fbe1c6"
	["zstd"]="2555975"
)

contrib_file() {
	local key=$1
	shift
	[[ -z "$1" ]] && echo "${contrib_versions[$key]}.tar.gz" || echo "${key}-${contrib_versions[$key]}.tar.gz"
}

contrib_mapping() {
	echo "$(contrib_file $1) -> $(contrib_file $1 $1)"
}

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
	SRC_URI="
		https://github.com/yandex/${MY_PN}/archive/v${PV}-${TYPE}.tar.gz -> ${P}.tar.gz
		https://github.com/google/cctz/archive/$(contrib_mapping cctz)
		!system-double-conversion? ( https://github.com/google/double-conversion/archive/$(contrib_mapping double-conversion) )
		test? ( !system-gtest? ( https://github.com/google/googletest/archive/$(contrib_mapping googletest) ) )
		!system-librdkafka? ( https://github.com/edenhill/librdkafka/archive/$(contrib_mapping librdkafka) )
		!system-lz4? ( https://github.com/lz4/lz4/archive/$(contrib_mapping lz4) )
		!system-poco? ( https://github.com/ClickHouse-Extras/poco/archive/$(contrib_mapping poco) )
		!system-re2? ( https://github.com/google/re2/archive/$(contrib_mapping re2) )
		!system-ssl? ( https://github.com/ClickHouse-Extras/ssl/archive/$(contrib_mapping ssl) )
		!system-zstd? ( https://github.com/facebook/zstd/archive/$(contrib_mapping zstd) )
	"
	S="${WORKDIR}/${MY_PN}-${PV}-${TYPE}"
fi

SLOT="0/${TYPE}"
IUSE=" +client doc kafka mongodb mysql +server static +system-double-conversion +system-gtest +system-librdkafka +system-libunwind +system-lz4 +system-poco +system-re2 +system-ssl +system-zstd test tools cpu_flags_x86_sse4_2"
KEYWORDS="~amd64"

REQUIRED_USE="
	server? ( cpu_flags_x86_sse4_2 )
	static? ( client server tools )
"

RDEPEND="
	dev-libs/re2:0=
	!static? (
		client? (
			sys-libs/ncurses:0
			sys-libs/readline:0
		)
		system-double-conversion? ( dev-libs/double-conversion )
		system-lz4? ( app-arch/lz4 )
		system-zstd? ( app-arch/zstd )
		kafka? ( system-librdkafka? ( dev-libs/librdkafka:= ) )
		system-libunwind? ( sys-libs/libunwind:7 )
		system-ssl? ( dev-libs/openssl:0= )

		dev-libs/capnproto
		dev-libs/libltdl:0
		sys-libs/zlib
		|| (
			dev-db/unixODBC
			dev-libs/poco[odbc]
		)
		dev-libs/icu:=
		dev-libs/glib
		>=dev-libs/boost-1.65.0:=
		dev-libs/zookeeper-c
		mysql? ( virtual/libmysqlclient )
	)
	dev-libs/libpcre
	system-poco? ( >=dev-libs/poco-1.9.0 )
"

DEPEND="${RDEPEND}
	doc? ( >=dev-python/mkdocs-0.17.3 )
	test? ( system-gtest? ( dev-cpp/gtest ) )
	static? (
		client? (
			sys-libs/ncurses:0=[static-libs]
			sys-libs/readline:0=[static-libs]
		)
		system-double-conversion? ( dev-libs/double-conversion[static-libs] )
		system-lz4? ( app-arch/lz4[static-libs] )
		system-zstd? ( app-arch/zstd[static-libs] )
		kafka? ( system-librdkafka? ( dev-libs/librdkafka[static-libs] ) )
		system-libunwind? ( sys-libs/libunwind:7[static-libs] )
		system-ssl? ( dev-libs/openssl[static-libs] )

		dev-libs/capnproto[static-libs]
		dev-libs/libltdl[static-libs]
		sys-libs/zlib[static-libs]
		|| (
			dev-db/unixODBC[static-libs]
			dev-libs/poco[odbc]
		)
		dev-libs/icu[static-libs]
		dev-libs/glib[static-libs]
		>=dev-libs/boost-1.65.0[static-libs]
		dev-libs/zookeeper-c[static-libs]
		virtual/libmysqlclient[static-libs]
	)
	dev-util/patchelf
	>=sys-devel/lld-6.0.0
	sys-libs/libtermcap-compat
	|| (
		>=sys-devel/gcc-7.0
		>=sys-devel/clang-5.0
	)
"

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
	mkdir -p cctz double-conversion googletest librdkafka lz4 re2 zstd
	tar --strip-components=1 -C cctz -xf "${DISTDIR}/cctz-4f9776a.tar.gz"
	use system-double-conversion || tar --strip-components=1 -C double-conversion -xf "${DISTDIR}/$(contrib_file double-conversion y)"
	use system-lz4 || tar --strip-components=1 -C lz4 -xf "${DISTDIR}/$(contrib_file lz4 y)"
	use system-poco || tar --strip-components=1 -C poco -xf "${DISTDIR}/$(contrib_file poco y)"
	use system-re2 || tar --strip-components=1 -C re2 -xf "${DISTDIR}/$(contrib_file re2 y)"
	use system-ssl || tar --strip-components=1 -C ssl -xf "${DISTDIR}/$(contrib_file ssl y)"
	use system-zstd || tar --strip-components=1 -C zstd -xf "${DISTDIR}/$(contrib_file zstd y)"
	if use kafka; then
		use system-librdkafka || tar --strip-components=1 -C librdkafka -xf "${DISTDIR}/$(contrib_file librdkafka y)"
	fi
	if use test; then
		use system-gtest || tar --strip-components=1 -C googletest -xf "${DISTDIR}/$(contrib_file googletest y)"
	fi
}

src_prepare() {
	cmake-utils_src_prepare
	#sed -i -r -e "s: -Wno-(for-loop-analysis|unused-local-typedef|unused-private-field): -Wno-unused-variable:g" \
	#	contrib/libpoco/CMakeLists.txt || die "Cannot patch poco"
	if use system-poco; then
		epatch "${FILESDIR}/system-poco.patch" || die "Cannot patch sources for usage with system Poco"
	fi
	if $(tc-getCC) -no-pie -v 2>&1 | grep -q unrecognized; then
		sed -i -e 's:--no-pie::' -i CMakeLists.txt || die "Cannot patch CMakeLists.txt"
		sed -i -e 's:-no-pie::' -i CMakeLists.txt || die "Cannot patch CMakeLists.txt"
	else
		sed -i -e 's:--no-pie:-no-pie:' -i CMakeLists.txt || die "Cannot patch CMakeLists.txt"
	fi

	sed -i -- "s/VERSION_REVISION .*)/VERSION_REVISION ${PV##*.})/g" dbms/cmake/version.cmake || die "Cannot patch version.cmake"
	sed -i -- "s/VERSION_DESCRIBE .*)/VERSION_DESCRIBE v${PV}-${TYPE})/g" dbms/cmake/version.cmake || die "Cannot patch version.cmake"
}

src_configure() {
	append-cxxflags $(test-flags-CXX -Wno-error=unused-parameter)
	local mycmakeargs=(
		-DENABLE_POCO_MONGODB="$(usex mongodb)"
		-DUSE_MYSQL="$(usex mysql)"
		-DENABLE_TESTS="$(usex test)"
		-DENABLE_CLICKHOUSE_SERVER="$(usex server)"
		-DENABLE_CLICKHOUSE_CLIENT="$(usex client)"
		-DENABLE_CLICKHOUSE_LOCAL="$(usex tools)"
		-DENABLE_CLICKHOUSE_BENCHMARK="$(usex tools)"
		-DENABLE_CLICKHOUSE_PERFORMANCE="$(usex tools)"
		-DENABLE_CLICKHOUSE_COPIER="$(usex tools)"
		-DENABLE_CLICKHOUSE_EXTRACT_FROM_CONFIG="$(usex tools)"
		-DENABLE_CLICKHOUSE_COMPRESSOR="$(usex tools)"
		-DENABLE_CLICKHOUSE_FORMAT="$(usex tools)"
		-DENABLE_CLICKHOUSE_OBFUSCATOR="$(usex tools)"
		-DENABLE_CLICKHOUSE_ALL=OFF
		-DUNBUNDLED=ON
		-DUSE_INTERNAL_CITYHASH_LIBRARY=ON # Clickhouse explicitly requires bundled patched cityhash
		-DUSE_INTERNAL_DOUBLE_CONVERSION_LIBRARY="$(usex !system-double-conversion)"
		-DUSE_INTERNAL_RDKAFKA_LIBRARY="$(usex !system-librdkafka)"
		-DUSE_INTERNAL_LZ4_LIBRARY="$(usex !system-lz4)"
		-DUSE_INTERNAL_POCO_LIBRARY="$(usex !system-poco)"
		-DUSE_INTERNAL_RE2_LIBRARY="$(usex !system-re2)"
		-DUSE_INTERNAL_SSL_LIBRARY="$(usex !system-ssl)"
		-DUSE_INTERNAL_UNWIND_LIBRARY="$(usex !system-libunwind)"
		-DUSE_INTERNAL_ZSTD_LIBRARY="$(usex !system-zstd)"
		-DUSE_STATIC_LIBRARIES="$(usex static)"
		-DMAKE_STATIC_LIBRARIES="$(usex static)"
	)

	if use test; then
		mycmakeargs+=(-DUSE_INTERNAL_GTEST_LIBRARY="$(usex !system-gtest)")
	fi

	cmake-utils_src_configure
}

src_install() {
	patchelf --remove-rpath dbms/src/Server/clickhouse

	cmake-utils_src_install

	if ! use test; then
		rm -rf "${ED}/usr/share/clickhouse-test" \
			   "${ED}/usr/bin/clickhouse-test" \
			   "${ED}/usr/bin/clickhouse-test-server" \
			   "${ED}/etc/clickhouse-client/server-test.xml" \
			   "${ED}/etc/clickhouse-server/server-test.xml" \
			   || die "failed to remove tests"
	fi

	if use doc; then
		pushd "${S}/docs/tools" || die "Failed to enter docs build directory"
		./build.py || die "Failed to build docs"
		popd || die "Failed to exit docs build directory"

		dodoc -r "${S}/docs/build"
	fi

	if use server; then
		newinitd "${FILESDIR}"/clickhouse-server.initd clickhouse-server
		systemd_dounit "${FILESDIR}"/clickhouse-server.service

		sed -e 's:/opt/clickhouse:/var/lib/clickhouse:g' -i "${ED}/etc/clickhouse-server/config.xml"
		sed -e '/listen_host/s%::<%::1<%' -i "${ED}/etc/clickhouse-server/config.xml"

		keepdir /var/lib/clickhouse/data/default /var/lib/clickhouse/metadata/default /var/lib/clickhouse/tmp
		keepdir /var/log/clickhouse-server
		fowners -R clickhouse:clickhouse /var/lib/clickhouse
		fperms -R 0750 /var/lib/clickhouse
		fowners -R clickhouse:adm /var/log/clickhouse-server
		fperms -R 0750 /var/log/clickhouse-server
	fi
}

pkg_setup() {
	if use server; then
		enewgroup clickhouse
		enewuser clickhouse -1 -1 /var/lib/clickhouse clickhouse
	fi
}
