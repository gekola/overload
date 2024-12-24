# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CMAKE_MAKEFILE_GENERATOR=ninja

inherit autotools cmake

CURL_VER="8.1.1"
BORING_SSL_COMMIT="1b7fdbd9101dedc3e0aa3fcf4ff74eacddb34ecc"
BROTLI_VER="1.0.9"
NGHTTP2_VER="1.56.0"
NSS_VER="3.92"

DESCRIPTION="A Client that groks URLs"
HOMEPAGE="https://github.com/lwthiker/curl-impersonate"
SRC_URI="
	https://github.com/lwthiker/curl-impersonate/archive/refs/tags/v${PV}.tar.gz -> curl-impersonate-${PV}.tar.gz
	https://curl.se/download/curl-${CURL_VER}.tar.xz
	https://github.com/google/boringssl/archive/${BORING_SSL_COMMIT}.zip -> boringssl-${BORING_SSL_COMMIT}.zip
	https://github.com/google/brotli/archive/refs/tags/v${BROTLI_VER}.tar.gz -> brotli-${BROTLI_VER}.tar.gz
	https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VER}/nghttp2-${NGHTTP2_VER}.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT=""
IUSE="static-libs"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="
	dev-lang/go
	>=dev-util/cmake-3.5
"

S="${WORKDIR}/curl-impersonate-${PV}"
CMAKE_BUILD_TYPE="Release"

src_prepare() {
	touch brotli-${BROTLI_VER}.tar.gz
	ln -s ../brotli-${BROTLI_VER} ./
	pushd brotli-${BROTLI_VER} > /dev/null || die
	mkdir out
	local CMAKE_USE_DIR="${WORKDIR}/brotli-${BROTLI_VER}"
	cmake_src_prepare
	popd > /dev/null || die

	touch boringssl.zip
	ln -s ../boringssl-* boringssl
	pushd boringssl > /dev/null || die
	for f in "${S}"/chrome/patches/boringssl-*.patch; do
		eapply -p1 "$f"

		local CMAKE_USE_DIR="${WORKDIR}/boringssl-${BORING_SSL_COMMIT}"
		cmake_src_prepare
	done
	touch .patched
	popd > /dev/null || die

	touch nghttp2-${NGHTTP2_VER}.tar.bz2
	ln -s ../nghttp2-${NGHTTP2_VER} ./

	touch curl-${CURL_VER}.tar.xz
	ln -s ../curl-${CURL_VER}
	pushd curl-${CURL_VER} > /dev/null || die
	for f in "${S}"/chrome/patches/curl-*.patch; do
		eapply -p1 "$f"
	done
  sed -e 's#pkgincludedir= $(includedir)/curl#pkgincludedir= $(includedir)/curl-impersonate-chrome/curl#' -i include/curl/Makefile.am || die
	touch .patched-chrome
	popd > /dev/null || die

	default
}

src_configure() {
	einfo "Configuring brotli ..."
	local BUILD_DIR="${WORKDIR}/brotli-${BROTLI_VER}/build"
	local CMAKE_USE_DIR="${WORKDIR}/brotli-${BROTLI_VER}"
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${WORKDIR}/brotli-${BROTLI_VER}/out/installed"
		-DCMAKE_INSTALL_LIBDIR=lib
		-DBUILD_SHARED_LIBS=OFF
	)
	cmake_src_configure

	einfo "Configuring boringssl ..."
	local BUILD_DIR="${WORKDIR}/boringssl-${BORING_SSL_COMMIT}/build"
	local CMAKE_USE_DIR="${WORKDIR}/boringssl-${BORING_SSL_COMMIT}"
	local mycmakeargs=(
		-DCMAKE_POSITION_INDEPENDENT_CODE=on
		-DCMAKE_C_FLAGS="-Wno-unknown-warning-option -Wno-stringop-overflow -Wno-array-bounds"
		-DBUILD_SHARED_LIBS=OFF
	)
	cmake_src_configure

	einfo "Configuring nghttp2 ..."
	pushd nghttp2-${NGHTTP2_VER} > /dev/null || die
	local config_flags=(
		--prefix="${S}/nghttp2-${NGHTTP2_VER}/installed"
		--with-pic
		--enable-lib-only
		--disable-shared
	)
	./configure ${config_flags[*]} || die
	popd > /dev/null || die
}

src_compile() {
	einfo "Building brotli ..."
	local BUILD_DIR="${WORKDIR}/brotli-${BROTLI_VER}/build"
	local CMAKE_USE_DIR="${WORKDIR}/brotli-${BROTLI_VER}"
	cmake_src_compile
	cmake_build install

	einfo "Building boringssl ..."
	local BUILD_DIR="${WORKDIR}/boringssl-${BORING_SSL_COMMIT}/build"
	local CMAKE_USE_DIR="${S}/boringssl-${BORING_SSL_COMMIT}"
	cmake_src_compile
	pushd "${WORKDIR}/boringssl-${BORING_SSL_COMMIT}/build" > /dev/null || die
	mkdir -p lib
	ln -sf ../crypto/libcrypto.a lib/libcrypto.a || die
	ln -sf ../ssl/libssl.a lib/libssl.a || die
	cp -Rf ../include . || die
	unset BUILD_DIR
	popd > /dev/null || die

	einfo "Building nghttp2 ..."
	pushd nghttp2-${NGHTTP2_VER} > /dev/null || die
	emake || die
	emake install || die
	popd > /dev/null || die

	einfo "Configuring curl ..."
	pushd curl-${CURL_VER} > /dev/null || die
	eautoreconf -fi
	local config_flags=(
		# impersonate flags
		--disable-rtsp
		--without-libidn2
		--without-zstd
		--with-nghttp2="${WORKDIR}/nghttp2-${NGHTTP2_VER}/installed"
		--with-brotli="${WORKDIR}/brotli-${BROTLI_VER}/out/installed"
		--with-openssl="${WORKDIR}/boringssl-${BORING_SSL_COMMIT}/build"
		--enable-websockets
		--with-zlib
		USE_CURL_SSLKEYLOGFILE=true
		# Gentoo flags
		$(use_enable static-libs static)
		--disable-ftp
		--disable-gopher
		--disable-imap
		--disable-ldap
		--disable-ldaps
		--enable-ntlm
		--disable-pop3
		--enable-rt
		--enable-rtsp
		--disable-smb
		--without-libssh2
		--disable-smtp
		--disable-telnet
		--disable-tftp
		--enable-cookies
		--enable-dateparse
		--enable-dnsshuffle
		--enable-doh
		--enable-symbol-hiding
		--enable-http-auth
		--enable-ipv6
		--enable-largefile
		--enable-manual
		--enable-mime
		--enable-netrc
		--enable-proxy
		--enable-socketpair
		--disable-sspi
		--enable-pthreads
		--enable-threaded-resolver
		--disable-versioned-symbols
		--without-amissl
		--without-bearssl
		--with-ca-bundle="${EPREFIX}"/etc/ssl/certs/ca-certificates.crt
		--with-ca-path="${EPREFIX}"/etc/ssl/certs
		--without-libgsasl
		--without-msh3
		--without-quiche
		--without-schannel
		--without-secure-transport
		--without-test-caddy
		--without-test-httpd
		--without-test-nghttpx
		--without-winidn
		--without-wolfssl
		--with-zsh-functions-dir="${EPREFIX}"/usr/share/zsh/site-functions
	)
	econf ${config_flags[*]} LIBS="-pthread"
	emake clean || die
	touch .chrome
	popd > /dev/null || die

	einfo "Configuring impersonate ..."
	econf --enable-static=$(usex static-libs yes no)

	einfo "Building impersonate ..."
	local CMAKE_USE_DIR="${S}/curl-${CURL_VER}"
	emake -C curl-${CURL_VER} || die
	emake chrome-checkbuild || die
}

src_install() {
	emake -C curl-${CURL_VER} DESTDIR="${D}" install-exec
	find "${ED}" -type f -name '*.la' -delete || die
	emake -C curl-${CURL_VER}/include DESTDIR="${D}" install
	for f in chrome/curl_*; do
		dobin $f
	done
}
