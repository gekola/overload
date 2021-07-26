# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_MAKEFILE_GENERATOR="ninja"

inherit check-reqs cmake flag-o-matic systemd

declare -A contrib_versions=(
	["arrow"]="b789226"
	["capnproto"]="a00ccd9"
	["cctz"]="4f9776a"
	["double-conversion"]="cf2f0f3"
	["googletest"]="703bd9c"
	["librdkafka"]="4ffe54b"
	["libunwind"]="ede0062"
	["lz4"]="3d67671"
	["orc"]="5981208"
	["poco"]="bc8ad1b"
	["re2"]="7cf8b88"
	["ryu"]="5b4a85"
	["ssl"]="07e962"
	["thrift"]="010ccf0"
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
CH_LTS=1

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/yandex/${MY_PN}.git"
	EGIT_SUBMODULES=( -private )
	SRC_URI=""
	TYPE="unstable"
else
	if [[ ${CH_LTS} == 1 ]]; then
		TYPE="lts"
	else
		TYPE="stable"
	fi
	SRC_URI="
		https://github.com/yandex/${MY_PN}/archive/v${PV}-${TYPE}.tar.gz -> ${P}.tar.gz
		https://github.com/google/cctz/archive/$(contrib_mapping cctz)
		https://github.com/ClickHouse-Extras/ryu/archive/$(contrib_mapping ryu)
		parquet? (
			https://github.com/apache/arrow/archive/$(contrib_mapping arrow)
			https://github.com/apache/thrift/archive/$(contrib_mapping thrift)
		)
		orc? ( https://github.com/apache/orc/archive/$(contrib_mapping orc) )
		unwind? ( !system-libunwind? ( https://github.com/ClickHouse-Extras/libunwind/archive/$(contrib_mapping libunwind) ) )
		!system-capnproto? ( https://github.com/capnproto/capnproto/archive/$(contrib_mapping capnproto) )
		!system-double-conversion? ( https://github.com/google/double-conversion/archive/$(contrib_mapping double-conversion) )
		test? ( !system-gtest? ( https://github.com/google/googletest/archive/$(contrib_mapping googletest) ) )
		!system-librdkafka? ( https://github.com/edenhill/librdkafka/archive/$(contrib_mapping librdkafka) )
		!system-lz4? ( https://github.com/lz4/lz4/archive/$(contrib_mapping lz4) )
		!system-poco? ( https://github.com/ClickHouse-Extras/poco/archive/$(contrib_mapping poco) )
		!system-re2? ( https://github.com/google/re2/archive/$(contrib_mapping re2) )
		!system-ssl? ( https://github.com/ClickHouse-Extras/openssl/archive/$(contrib_mapping ssl) )
		!system-zstd? ( https://github.com/facebook/zstd/archive/$(contrib_mapping zstd) )
	"
	S="${WORKDIR}/${MY_PN}-${PV}-${TYPE}"
fi

SLOT="0/${TYPE}"
IUSE="+client doc jemalloc kafka lld lto mongodb mysql orc parquet redis s3 +server static +system-capnproto +system-double-conversion +system-gtest +system-librdkafka +system-libunwind +system-lz4 +system-poco +system-re2 +system-ssl +system-zstd test tools unwind cpu_flags_x86_sse4_2"
KEYWORDS="~amd64"

REQUIRED_USE="
	parquet? ( orc )
	server? ( cpu_flags_x86_sse4_2 )
	static? ( client server tools )
"
#	test? ( !system-gtest )
#"

RDEPEND="
	dev-libs/libpcre
	dev-libs/re2:0=
	s3? ( dev-libs/aws-sdk-cpp[s3] )
	server? ( acct-group/clickhouse acct-user/clickhouse )
	!static? (
		client? (
			sys-libs/ncurses:0
			sys-libs/readline:0
		)
		system-capnproto? ( >=dev-libs/capnproto-0.7.0 )
		system-double-conversion? ( dev-libs/double-conversion )
		system-lz4? ( app-arch/lz4 )
		system-zstd? ( app-arch/zstd )
		jemalloc? ( dev-libs/jemalloc )
		kafka? ( system-librdkafka? ( dev-libs/librdkafka:= ) )
		unwind? ( system-libunwind? ( sys-libs/libunwind:= ) )
		system-ssl? ( dev-libs/openssl:0= )

		dev-libs/libltdl:0
		sys-libs/zlib
		|| (
			dev-db/unixODBC
			dev-libs/poco[odbc]
		)
		dev-libs/icu:=
		dev-libs/glib
		dev-libs/libfmt
		>=dev-libs/boost-1.65.0:=
		dev-libs/protobuf:=
		mysql? ( dev-db/mysql-connector-c )
		orc? ( dev-libs/cyrus-sasl:2= )
	)
	system-poco? ( >=dev-libs/poco-1.9.0 )
	net-libs/grpc:=
"

DEPEND="${RDEPEND}
	doc? ( >=dev-python/mkdocs-1.0.1 )
	test? ( system-gtest? ( dev-cpp/gtest ) )
	static? (
		client? (
			sys-libs/ncurses:0=[static-libs]
			sys-libs/readline:0=[static-libs]
		)
		system-lz4? ( app-arch/lz4[static-libs] )
		system-zstd? ( app-arch/zstd[static-libs] )
		kafka? ( system-librdkafka? ( dev-libs/librdkafka[static-libs] ) )
		unwind? ( system-libunwind? ( sys-libs/libunwind[static-libs] ) )
		system-ssl? ( dev-libs/openssl[static-libs] )

		system-capnproto? ( dev-libs/capnproto[static-libs] )
		dev-libs/libltdl[static-libs]
		sys-libs/zlib[static-libs]
		|| (
			dev-db/unixODBC[static-libs]
			dev-libs/poco[odbc]
		)
		dev-libs/icu[static-libs]
		dev-libs/glib[static-libs]
		>=dev-libs/boost-1.65.0[static-libs]
		dev-libs/protobuf[static-libs]
		dev-db/mysql-connector-c[static-libs]
		orc? ( dev-libs/cyrus-sasl:2[static-libs] )
	)
	dev-cpp/sparsehash
	dev-util/patchelf
	lld? ( >=sys-devel/lld-6.0.0 )
	!lld? ( sys-devel/binutils[gold] )
	sys-devel/llvm
	sys-libs/libtermcap-compat
	|| (
		>=sys-devel/gcc-8.0
		>=sys-devel/clang-8.0
	)
"

PATCHES=(
		"${FILESDIR}/${PN}-20.3-fix-mysql8.patch"
		"${FILESDIR}/${PN}-20.1-allow-system-flatbuffers.patch"
		"${FILESDIR}/${PN}-20.1-allow-system-s3.patch"
		"${FILESDIR}/${PN}-20.3-enforce-static-internal-libs-r1.patch"
		"${FILESDIR}/${PN}-allow-system-unwind-r3.patch"
		"${FILESDIR}/${PN}-20.3-system-grpc.patch"
		"${FILESDIR}/${PN}-20.3-system-libc.patch"
		"${FILESDIR}/${PN}-20.3-fix-readline.patch"
		"${FILESDIR}/${PN}-20.3-fix-versions.patch"
		"${FILESDIR}/${PN}-20.3-fix-headers.patch"
		"${FILESDIR}/${PN}-20.3-system-libfmt.patch"
		"${FILESDIR}/${PN}-20.3-fix-atomic.patch"
		"${FILESDIR}/${PN}-20.3-fix-capnp.patch"
)

CHECKREQS_DISK_BUILD="2G"

pkg_pretend() {
	check-reqs_pkg_pretend
	if [[ $(tc-getCC) == clang ]]; then
		:
	elif [[ $(gcc-major-version) -lt 8 ]]; then
		eerror "Compilation with gcc older than 8.0 is not supported"
		die "Too old gcc found."
	fi
}

src_unpack() {
	default_src_unpack
	[[ ${PV} == 9999 ]] && return 0
	cd "${S}/contrib"
	mkdir -p arrow cctz double-conversion googletest librdkafka lz4 orc re2 ryu thrift zstd
	for comp in cctz ryu; do
		tar --strip-components=1 -C $comp -xf "${DISTDIR}/$(contrib_file $comp y)" || die
	done
	if use orc; then
		tar --strip-components=1 -C orc -xf "${DISTDIR}/$(contrib_file orc y)" || die
	fi
	if use parquet; then
		tar --strip-components=1 -C arrow -xf "${DISTDIR}/$(contrib_file arrow y)" || die
		tar --strip-components=1 -C thrift -xf "${DISTDIR}/$(contrib_file thrift y)" || die
	fi
	use system-capnproto || tar --strip-components=1 -C capnproto -xf "${DISTDIR}/$(contrib_file capnproto y)" || die
	use system-double-conversion || tar --strip-components=1 -C double-conversion -xf "${DISTDIR}/$(contrib_file double-conversion y)" || die
	use system-lz4 || tar --strip-components=1 -C lz4 -xf "${DISTDIR}/$(contrib_file lz4 y)" || die
	use system-poco || tar --strip-components=1 -C poco -xf "${DISTDIR}/$(contrib_file poco y)" || die
	use system-re2 || tar --strip-components=1 -C re2 -xf "${DISTDIR}/$(contrib_file re2 y)" || die
	use system-ssl || tar --strip-components=1 -C openssl -xf "${DISTDIR}/$(contrib_file ssl y)" || die
	use system-zstd || tar --strip-components=1 -C zstd -xf "${DISTDIR}/$(contrib_file zstd y)" || die
	if use kafka; then
		use system-librdkafka || tar --strip-components=1 -C librdkafka -xf "${DISTDIR}/$(contrib_file librdkafka y)" || die
	fi
	if use test; then
		use system-gtest || tar --strip-components=1 -C googletest -xf "${DISTDIR}/$(contrib_file googletest y)" || die
	fi
}

src_prepare() {
	cmake_src_prepare
	#sed -i -r -e "s: -Wno-(for-loop-analysis|unused-local-typedef|unused-private-field): -Wno-unused-variable:g" \
	#	contrib/libpoco/CMakeLists.txt || die "Cannot patch poco"
	if use system-poco; then
		eapply "${FILESDIR}/${PN}-20.3-system-poco-r1.patch" || die "Cannot patch sources for usage with system Poco"
	fi
	if $(tc-getCC) -no-pie -v 2>&1 | grep -q unrecognized; then
		sed -i -e 's:--no-pie::' -i CMakeLists.txt || die "Cannot patch CMakeLists.txt"
		sed -i -e 's:-no-pie::' -i CMakeLists.txt || die "Cannot patch CMakeLists.txt"
	else
		sed -i -e 's:--no-pie:-no-pie:' -i CMakeLists.txt || die "Cannot patch CMakeLists.txt"
	fi

	sed -i -- "s/VERSION_DESCRIBE .*)/VERSION_DESCRIBE v${PV}-${TYPE})/g" cmake/version.cmake || die "Cannot patch version.cmake"
}

src_configure() {
	append-cxxflags $(test-flags-CXX -Wno-error=unused-parameter)
	local mycmakeargs=(
		-DENABLE_JEMALLOC="$(usex jemalloc)"
		-DENABLE_PARQUET="$(usex parquet)"
		-DUSE_INTERNAL_PARQUET_LIBRARY=$(usex parquet)
		-DENABLE_POCO_MONGODB="$(usex mongodb)"
		-DENABLE_POCO_REDIS="$(usex redis)"
		-DENABLE_RDKAFKA="$(usex kafka)"
		-DENABLE_READLINE=ON
		-DENABLE_REPLXX=OFF
		-DENABLE_S3="$(usex s3)"
		-DENABLE_TESTS="$(usex test)"
		-DUSE_MYSQL="$(usex mysql)"
		-DUSE_SNAPPY="$(usex parquet)"
		-DUSE_UNWIND="$(usex unwind)"
		-DENABLE_CLICKHOUSE_SERVER="$(usex server)"
		-DENABLE_CLICKHOUSE_CLIENT="$(usex client)"
		-DENABLE_CLICKHOUSE_LOCAL="$(usex tools)"
		-DENABLE_CLICKHOUSE_BENCHMARK="$(usex tools)"
		-DENABLE_CLICKHOUSE_COPIER="$(usex tools)"
		-DENABLE_CLICKHOUSE_EXTRACT_FROM_CONFIG="$(usex tools)"
		-DENABLE_CLICKHOUSE_COMPRESSOR="$(usex tools)"
		-DENABLE_CLICKHOUSE_FORMAT="$(usex tools)"
		-DENABLE_CLICKHOUSE_OBFUSCATOR="$(usex tools)"
		-DENABLE_CLICKHOUSE_ALL=OFF
		-DUNBUNDLED=ON
		-DUSE_INTERNAL_CITYHASH_LIBRARY=ON # Clickhouse explicitly requires bundled patched cityhash
		-DUSE_INTERNAL_CAPNP_LIBRARY="$(usex !system-capnproto)"
		-DUSE_INTERNAL_DOUBLE_CONVERSION_LIBRARY="$(usex !system-double-conversion)"
		-DUSE_INTERNAL_RDKAFKA_LIBRARY="$(usex !system-librdkafka)"
		-DUSE_INTERNAL_LZ4_LIBRARY="$(usex !system-lz4)"
		-DUSE_INTERNAL_ORC_LIBRARY="$(usex orc)"
		-DUSE_INTERNAL_POCO_LIBRARY="$(usex !system-poco)"
		-DUSE_INTERNAL_RE2_LIBRARY="$(usex !system-re2)"
		-DUSE_INTERNAL_SSL_LIBRARY="$(usex !system-ssl)"
		-DUSE_INTERNAL_UNWIND_LIBRARY="$(usex !system-libunwind)"
		-DUSE_INTERNAL_ZSTD_LIBRARY="$(usex !system-zstd)"
		-DUSE_STATIC_LIBRARIES="$(usex static)"
		-DMAKE_STATIC_LIBRARIES="$(usex static)"
		-DENABLE_EMBEDDED_COMPILER=OFF
		-DENABLE_IPO=$(usex lto)
		-DLINKER_NAME=$(usex lld lld gold)
		# build fails w/o odbc
		-DENABLE_ODBC=True
		-DENABLE_CLICKHOUSE_ODBC_BRIDGE=True
		# Let portage handle ccache, otherwise sandbox fails when FEATURES=-ccache
		-DCCACHE_FOUND=0
	)

	if use test; then
		mycmakeargs+=(-DUSE_INTERNAL_GTEST_LIBRARY="$(usex !system-gtest)")
	fi

	cmake_src_configure
}

src_install() {
	patchelf --remove-rpath src/Server/clickhouse

	cmake_src_install

	rm -rf "${ED}/usr/cmake"

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
