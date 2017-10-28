# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit eutils

DESCRIPTION="A library that provides an embeddable, persistent key-value store for fast storage"
HOMEPAGE="http://rocksdb.org"
SRC_URI="https://github.com/facebook/${PN}/archive/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+bzip2 jemalloc +lz4 +snappy static-libs +tbb +zlib +zstd"

RDEPEND="
	dev-cpp/gflags
	bzip2? ( app-arch/bzip2 )
	jemalloc? ( dev-libs/jemalloc )
	lz4? ( app-arch/lz4 )
	snappy? ( app-arch/snappy )
	tbb? ( dev-cpp/tbb )
	zlib? ( sys-libs/zlib )
	zstd? ( app-arch/zstd )
"
DEPEND="
	${RDEPEND}
"

src_unpack() {
	default
	mv rocksdb-${P} ${P}
}

src_prepare() {
	sed -i "s#\$(INSTALL_PATH)/lib#\$(INSTALL_PATH)/$(get_libdir)#g" Makefile
	default
}

src_compile() {
	emake DEBUG_LEVEL=0 shared_lib
	use static-libs && emake DEBUG_LEVEL=0 static_lib
}

src_install() {
	emake DEBUG_LEVEL=0 INSTALL_PATH="${D}/usr" install-shared install-headers
	use static-libs && emake DEBUG_LEVEL=0 INSTALL_PATH="${D}/usr" install-static 
}
