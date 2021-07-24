# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_MAKEFILE_GENERATOR="ninja"

inherit check-reqs cmake flag-o-matic systemd

declare -A contrib_versions=(
	["antlr4-runtime"]="a2fa7b76e2ee16d2ad955e9214a90bbf79da66fc"
	["arrow"]="744bdfe188f018e5e05f5deebd4e9ee0a7706cf4"
	["capnproto"]="a00ccd91b3746ef2ab51d40fe3265829949d1ace"
	["cctz"]="c0f1bcb97fd2782f7c3f972fadd5aad5affac4b8"
	["croaring"]="d8402939b5c9fc134fd4fcf058fe0f7006d2b129"
	["double-conversion"]="cf2f0f3d547dc73b4612028a155b80536902ba02"
	["dragonbox"]="923705af6fd953aa948fc175f6020b15f7359838"
	["fast_float"]="7eae925b51fd0f570ccd5c880c12e3e27a23b86f"
	["fmtlib"]="c108ee1d590089ccf642fc85652b845924067af2"
	["googletest"]="356f2d264a485db2fcc50ec1c672e0d37b6cb39b"
	["jemalloc"]="e6891d9746143bf2cf617493d880ba5a0b9a3efd"
	["librdkafka"]="cf11d0aa36d4738f2c9bf4377807661660f1be76"
	["libunwind"]="8fe25d7dc70f2a4ea38c3e5a33fa9d4199b67a5a"
	["lz4"]="f39b79fb02962a1cd880bbdecb6dffba4f754a11"
	["miniselect"]="be0af6bd0b6eb044d1acc4f754b229972d99903a"
	["orc"]="5981208e39447df84827f6a961d1da76bacb6078"
	["poco"]="c55b91f394efa9c238c33957682501681ef9b716"
	["re2"]="7cf8b88e8f70f97fd4926b56aa87e7f53b2717e0"
	["thrift"]="010ccf0a0c7023fea0f6bf4e4078ebdff7e61982"
	["zstd"]="10f0e6993f9d2f682da6d04aa2385b7d53cbb4ee"
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
		https://github.com/ClickHouse-Extras/antlr4-runtime/archive/$(contrib_mapping antlr4-runtime)
		https://github.com/ClickHouse-Extras/cctz/archive/$(contrib_mapping cctz)
		https://github.com/RoaringBitmap/CRoaring/archive/$(contrib_mapping croaring)
		https://github.com/ClickHouse-Extras/dragonbox/archive/$(contrib_mapping dragonbox)
		https://github.com/fastfloat/fast_float/archive/$(contrib_mapping fast_float)
		https://github.com/danlark1/miniselect/archive/$(contrib_mapping miniselect)
		parquet? (
			https://github.com/apache/arrow/archive/$(contrib_mapping arrow)
			https://github.com/apache/thrift/archive/$(contrib_mapping thrift)
		)
		orc? ( https://github.com/apache/orc/archive/$(contrib_mapping orc) )
		unwind? ( !system-libunwind? ( https://github.com/ClickHouse-Extras/libunwind/archive/$(contrib_mapping libunwind) ) )
		!system-capnproto? ( https://github.com/capnproto/capnproto/archive/$(contrib_mapping capnproto) )
		!system-double-conversion? ( https://github.com/google/double-conversion/archive/$(contrib_mapping double-conversion) )
		!system-fmt? ( https://github.com/fmtlib/fmt/archive/$(contrib_mapping fmtlib) )
		test? ( !system-gtest? ( https://github.com/google/googletest/archive/$(contrib_mapping googletest) ) )
		jemalloc? ( !system-jemalloc? ( https://github.com/ClickHouse-Extras/jemalloc/archive/$(contrib_mapping jemalloc) ) )
		!system-librdkafka? ( https://github.com/ClickHouse-Extras/librdkafka/archive/$(contrib_mapping librdkafka) )
		!system-lz4? ( https://github.com/lz4/lz4/archive/$(contrib_mapping lz4) )
		!system-poco? ( https://github.com/ClickHouse-Extras/poco/archive/$(contrib_mapping poco) )
		!system-re2? ( https://github.com/google/re2/archive/$(contrib_mapping re2) )
		!system-zstd? ( https://github.com/facebook/zstd/archive/$(contrib_mapping zstd) )
	"
	S="${WORKDIR}/${MY_PN}-${PV}-${TYPE}"
fi

SLOT="0/${TYPE}"
IUSE="+client doc jemalloc kafka kerberos lld lto mysql orc parquet s3 +server static
		+system-capnproto +system-double-conversion system-fmt +system-gtest -system-jemalloc +system-librdkafka
		+system-libunwind +system-lz4 -system-poco +system-re2 +system-zstd
		test tools unwind cpu_flags_x86_sse4_2"
KEYWORDS="~amd64"

REQUIRED_USE="
	parquet? ( orc )
	s3? ( !system-poco )
	server? ( cpu_flags_x86_sse4_2 )
	static? ( client server tools )

	system-poco? ( !system-poco )
	system-jemalloc? ( !system-jemalloc )
"
#	test? ( !system-gtest )
#"

RDEPEND="
	dev-libs/libpcre
	dev-libs/re2:0=
	kerberos? ( virtual/krb5 )
	s3? ( dev-libs/aws-sdk-cpp[s3] )
	server? ( acct-group/clickhouse acct-user/clickhouse )
	!static? (
		client? (
			sys-libs/ncurses:0
			sys-libs/readline:0
		)
		system-capnproto? ( >=dev-libs/capnproto-0.7.0 )
		system-double-conversion? ( dev-libs/double-conversion )
		system-fmt? ( dev-libs/libfmt )
		jemalloc? ( system-jemalloc? ( dev-libs/jemalloc ) )
		system-lz4? ( app-arch/lz4 )
		system-zstd? ( app-arch/zstd )
		kafka? ( system-librdkafka? ( dev-libs/librdkafka:= ) )
		unwind? ( system-libunwind? ( sys-libs/libunwind:= ) )
		dev-libs/openssl:0=

		dev-libs/libltdl:0
		sys-libs/zlib
		|| (
			dev-db/unixODBC
			dev-libs/poco[odbc]
		)
		dev-libs/icu:=
		dev-libs/glib
		>=dev-libs/boost-1.65.0:=
		mysql? ( dev-db/mysql-connector-c )
		orc? ( dev-libs/cyrus-sasl:2= )
	)
	system-poco? ( >=dev-libs/poco-1.10.0[mongodb] )
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
		dev-libs/openssl[static-libs]

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
		"${FILESDIR}/${PN}-21.3-allow-system-flatbuffers.patch"
		"${FILESDIR}/${PN}-21.3-allow-system-s3.patch"
		"${FILESDIR}/${PN}-21.3-enforce-static-internal-libs.patch"
		"${FILESDIR}/${PN}-21.3-allow-system-unwind.patch"
		"${FILESDIR}/${PN}-21.3-fix-versions.patch"
		"${FILESDIR}/${PN}-21.3-fix-clickhouse-server-target.patch"
		"${FILESDIR}/${PN}-21.3-system-grpc.patch"
		"${FILESDIR}/${PN}-21.3-system-xz.patch"
		"${FILESDIR}/${PN}-21.3-fix-compilation.patch"
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
	rm -rf antlr4-runtime arrow cctz croaring double-conversion dragonbox fast_float fmtlib googletest jemalloc librdkafka lz4 miniselect orc poco re2 thrift zstd
	for comp in antlr4-runtime cctz dragonbox fast_float miniselect; do
		ln -s "${WORKDIR}/${comp}-"* "$comp" || die
	done

	ln -s "${WORKDIR}/CRoaring-"* croaring || die

	if use orc; then
		ln -s "${WORKDIR}/orc-"* orc || die
	fi
	if use parquet; then
		ln -s "${WORKDIR}/arrow-"* arrow || die
		ln -s "${WORKDIR}/thrift-"* thrift || die
	fi
	use system-capnproto || ln -s "${WORKDIR}/capnproto-"* capnproto || die
	use system-double-conversion || ln -s "${WORKDIR}/double-conversion-"* double-conversion || die
	use system-fmt || ln -s "${WORKDIR}/fmt-"* fmtlib || die
	use system-lz4 || ln -s "${WORKDIR}/lz4-"* lz4 || die
	use system-poco || ln -s "${WORKDIR}/poco-"* poco || die
	use system-re2 || ln -s "${WORKDIR}/re2-"* re2 || die
	use system-zstd || ln -s "${WORKDIR}/zstd-"* zstd || die
	if use jemalloc; then
		use system-jemalloc || ln -s "${WORKDIR}/jemalloc-"* jemalloc || die
	fi
	if use kafka; then
		use system-librdkafka || ln -s "${WORKDIR}/librdkafka-"* librdkafka || die
	fi
	if use test; then
		use system-gtest || ln -s "${WORKDIR}/googletest-"* googletest || die
	fi
}

src_prepare() {
	cmake_src_prepare
	#sed -i -r -e "s: -Wno-(for-loop-analysis|unused-local-typedef|unused-private-field): -Wno-unused-variable:g" \
	#	contrib/libpoco/CMakeLists.txt || die "Cannot patch poco"
	if use system-poco; then
		eapply "${FILESDIR}/${PN}-21.3-system-poco.patch" || die "Cannot patch sources for usage with system Poco"
	fi
	if use system-fmt; then
		eapply "${FILESDIR}/${PN}-21.3-system-libfmt.patch" || die "Cannot patch sources for usage with libfmt"
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
		-DENABLE_AMQPCPP=OFF
		-DENABLE_AVRO=OFF
		-DENABLE_BASE64=OFF
		-DENABLE_CASSANDRA=OFF
		-DENABLE_CPUID=OFF
		-DENABLE_FASTOPS=OFF
		-DENABLE_GSASL_LIBRARY=OFF
		-DENABLE_H3=OFF
		-DENABLE_HDFS=OFF
		-DENABLE_HYPERSCAN=OFF
		-DENABLE_JEMALLOC=$(usex jemalloc)
		-DENABLE_KRB5="$(usex kerberos)"
		-DENABLE_LDAP=OFF
		-DENABLE_MSGPACK=OFF
		-DENABLE_NURAFT=OFF
		-DENABLE_PARQUET="$(usex parquet)"
		-DENABLE_LIBPQXX=OFF
		-DENABLE_RAPIDJSON=OFF
		-DENABLE_ROCKSDB=OFF
		-DUSE_INTERNAL_AWS_S3_LIBRARY=OFF
		-DUSE_INTERNAL_PARQUET_LIBRARY=$(usex parquet)
		-DENABLE_RDKAFKA="$(usex kafka)"
		-DENABLE_READLINE=ON
		-DENABLE_REPLXX=OFF
		-DENABLE_S3="$(usex s3)"
		-DENABLE_STATS=OFF
		-DENABLE_TESTS="$(usex test)"
		-DUSE_MYSQL="$(usex mysql)"
		-DUSE_SIMDJSON=OFF
		-DUSE_SNAPPY=$(usex parquet)
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
		-DUSE_INTERNAL_CCTZ_LIBRARY=ON # Not present in portage tree
		-DUSE_INTERNAL_CITYHASH_LIBRARY=ON # Clickhouse explicitly requires bundled patched cityhash
		-DUSE_INTERNAL_FARMHASH_LIBRARY=ON # Clickhouse is shipped with farmhash sources bundled
		-DUSE_INTERNAL_CAPNP_LIBRARY="$(usex !system-capnproto)"
		-DUSE_INTERNAL_DOUBLE_CONVERSION_LIBRARY="$(usex !system-double-conversion)"
		-DUSE_INTERNAL_RDKAFKA_LIBRARY="$(usex !system-librdkafka)"
		-DUSE_INTERNAL_LZ4_LIBRARY="$(usex !system-lz4)"
		-DUSE_INTERNAL_ORC_LIBRARY="$(usex orc)"
		-DUSE_INTERNAL_POCO_LIBRARY="$(usex !system-poco)"
		-DUSE_INTERNAL_RE2_LIBRARY="$(usex !system-re2)"
		# -DUSE_INTERNAL_SSL_LIBRARY="$(usex !system-ssl)"
		-DUSE_INTERNAL_UNWIND_LIBRARY="$(usex !system-libunwind)"
		-DUSE_INTERNAL_ZSTD_LIBRARY="$(usex !system-zstd)"
		-DUSE_STATIC_LIBRARIES="$(usex static)"
		-DMAKE_STATIC_LIBRARIES="$(usex static)"
		-DENABLE_EMBEDDED_COMPILER=OFF
		-DLINKER_NAME=$(usex lld lld gold)
		-DCLICKHOUSE_SPLIT_BINARY=OFF
		# build fails w/o odbc
		-DENABLE_ODBC=OFF
		-DENABLE_CLICKHOUSE_ODBC_BRIDGE=ON
		# Let portage handle ccache, otherwise sandbox fails when FEATURES=-ccache
		-DCCACHE_FOUND=OFF
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
