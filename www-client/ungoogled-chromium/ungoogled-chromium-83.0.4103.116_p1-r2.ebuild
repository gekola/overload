# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{2_7,3_{7,8}} )

CHROMIUM_LANGS="am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk vi zh-CN zh-TW"

inherit check-reqs chromium-2 desktop flag-o-matic ninja-utils pax-utils python-r1 readme.gentoo-r1 toolchain-funcs xdg-utils

UGC_PV="${PV/_p/-}"
UGC_P="${PN}-${UGC_PV}"
UGC_WD="${WORKDIR}/${UGC_P}"
UGC_PATCHES_PV="${UGC_PV}.sid3"
UGC_PATCHES_PN="${PN}-debian"
UGC_PATCHES_P="${UGC_PATCHES_PN}-${UGC_PATCHES_PV}"
UGC_PATCHES_WD="${WORKDIR}/${UGC_PATCHES_P}"


DESCRIPTION="Modifications to Chromium for removing Google integration and enhancing privacy"
HOMEPAGE="https://www.chromium.org/Home https://github.com/Eloston/ungoogled-chromium"
SRC_URI="
	https://commondatastorage.googleapis.com/chromium-browser-official/chromium-${PV/_*}.tar.xz
	https://github.com/Eloston/${PN}/archive/${UGC_PV}.tar.gz -> ${UGC_P}.tar.gz
	https://github.com/ungoogled-software/${UGC_PATCHES_PN}/archive/${UGC_PATCHES_PV}.tar.gz -> ${UGC_PATCHES_P}.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="
	+cfi +clang closure-compile cups custom-cflags gnome gold jumbo-build
	kerberos libcxx +lld optimize-thinlto optimize-webui +pdf
	+proprietary-codecs pulseaudio selinux +suid +system-double-conversion
	+system-ffmpeg system-harfbuzz
	+system-icu	+system-jsoncpp +system-libevent +system-libvpx +system-openh264
	+system-openjpeg +tcmalloc +thinlto vaapi widevine
"
REQUIRED_USE="
	^^ ( gold lld )
	|| ( $(python_gen_useflags 'python2*') )
	|| ( $(python_gen_useflags 'python3*') )
	cfi? ( clang thinlto )
	optimize-thinlto? ( thinlto )
	system-openjpeg? ( pdf )
	thinlto? ( clang )
	x86? ( !lld !thinlto !widevine )
"
RESTRICT="
	!system-ffmpeg? ( proprietary-codecs? ( bindist ) )
	!system-openh264? ( bindist )
"

CDEPEND="
	>=app-accessibility/at-spi2-atk-2.26:2
	app-arch/bzip2:=
	>=dev-libs/atk-2.26
	dev-libs/expat:=
	dev-libs/glib:2
	>=dev-libs/libxml2-2.9.4-r3:=[icu]
	dev-libs/libxslt:=
	dev-libs/nspr:=
	>=dev-libs/nss-3.26:=
	>=dev-libs/re2-0.2018.10.01:=
	>=media-libs/alsa-lib-1.0.19:=
	media-libs/flac:=
	media-libs/fontconfig:=
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	>=media-libs/libwebp-0.4.0:=
	sys-apps/dbus:=
	sys-apps/pciutils:=
	sys-libs/zlib:=[minizip]
	virtual/udev
	x11-libs/cairo:=
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libX11:=
	x11-libs/libXcomposite:=
	x11-libs/libXcursor:=
	x11-libs/libXdamage:=
	x11-libs/libXext:=
	x11-libs/libXfixes:=
	>=x11-libs/libXi-1.6.0:=
	x11-libs/libXrandr:=
	x11-libs/libXrender:=
	x11-libs/libXScrnSaver:=
	x11-libs/libXtst:=
	x11-libs/libdrm:=
	x11-libs/pango:=
	closure-compile? ( virtual/jre:* )
	cups? ( >=net-print/cups-1.3.11:= )
	kerberos? ( virtual/krb5 )
	pdf? ( media-libs/lcms:= )
	pulseaudio? ( media-sound/pulseaudio:= )
	system-ffmpeg? (
		>=media-video/ffmpeg-3.4.5:=
		|| (
			media-video/ffmpeg[-samba]
			>=net-fs/samba-4.5.16[-debug(-)]
		)
		media-libs/opus:=
	)
	system-harfbuzz? (
		media-libs/freetype:=
		>=media-libs/harfbuzz-2.4.0:0=[icu(-)]
	)
	system-icu? ( >=dev-libs/icu-65:= )
	system-jsoncpp? ( dev-libs/jsoncpp )
	system-libevent? ( dev-libs/libevent )
	system-libvpx? ( >=media-libs/libvpx-1.8.1-r100:=[postproc,svc] )
	system-openh264? ( >=media-libs/openh264-1.6.0:= )
	system-openjpeg? ( media-libs/openjpeg:2= )
	vaapi? ( x11-libs/libva:= )
"
RDEPEND="${CDEPEND}
	virtual/opengl
	virtual/ttf-fonts
	x11-misc/xdg-utils
	selinux? ( sec-policy/selinux-chromium )
	!www-client/chromium
	!www-client/ungoogled-chromium-bin
"
# dev-vcs/git (Bug #593476)
# sys-apps/sandbox - https://crbug.com/586444
DEPEND="${CDEPEND}"
BDEPEND="
	>=app-arch/gzip-1.7
	dev-lang/perl
	dev-lang/yasm
	dev-util/gn
	>=dev-util/gperf-3.0.3
	>=dev-util/ninja-1.7.2
	dev-vcs/git
	sys-apps/hwids[usb(+)]
	>=sys-devel/bison-2.4.3
	clang? ( >=sys-devel/clang-8.0.0[static-analyzer] )
	sys-devel/flex
	>=sys-devel/llvm-7.0.0[gold?]
	virtual/libusb:1
	virtual/pkgconfig
	cfi? ( clang? ( >=sys-devel/clang-runtime-7.0.0[sanitize] ) )
	libcxx? (
		sys-libs/libcxx
		sys-libs/libcxxabi
	)
	lld? ( >=sys-devel/lld-7.0.0 )
	optimize-webui? ( >=net-libs/nodejs-7.6.0[inspector] )
"

# shellcheck disable=SC2086
if ! has chromium_pkg_die ${EBUILD_DEATH_HOOKS}; then
	EBUILD_DEATH_HOOKS+=" chromium_pkg_die";
fi

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
Some web pages may require additional fonts to display properly.
Try installing some of the following packages if some characters
are not displayed properly:
- media-fonts/arphicfonts
- media-fonts/droid
- media-fonts/ipamonafont
- media-fonts/noto
- media-fonts/noto-emoji
- media-fonts/ja-ipafonts
- media-fonts/takao-fonts
- media-fonts/wqy-microhei
- media-fonts/wqy-zenhei

To fix broken icons on the Downloads page, you should install an icon
theme that covers the appropriate MIME types, and configure this as your
GTK+ icon theme.

For native file dialogs in KDE, install kde-apps/kdialog.
"

PATCHES=(
	"${FILESDIR}/${PN}-compiler-r7.patch"
	"${FILESDIR}/${PN}-fix-gcc.patch"
	"${FILESDIR}/${PN}-gold-r6.patch"
	"${UGC_PATCHES_WD}/debian/patches/gn/libcxx.patch"
	"${UGC_PATCHES_WD}/debian/patches/arm/pffffft-buildfix.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/mojo.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/gnu-as.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/breakpad.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/ordering.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/gpu-timeout.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/sequence-point.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/jumbo-namespace.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/incomplete-type.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/missing-includes.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/lambda-expression.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/widevine-enable-version-string.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/nullptr-dereference.patch"
	"${UGC_PATCHES_WD}/debian/patches/fixes/serviceworker-double-destruction.patch"
	"${UGC_PATCHES_WD}/debian/patches/disable/tests.patch"
	"${UGC_PATCHES_WD}/debian/patches/disable/glmark.patch"
	"${UGC_PATCHES_WD}/debian/patches/disable/owners.patch"
	"${UGC_PATCHES_WD}/debian/patches/disable/buildbot.patch"
	"${UGC_PATCHES_WD}/debian/patches/disable/installer.patch"
	"${UGC_PATCHES_WD}/debian/patches/disable/font-tests.patch"
	"${UGC_PATCHES_WD}/debian/patches/disable/swiftshader.patch"
	"${UGC_PATCHES_WD}/debian/patches/system/re2.patch"
	"${UGC_PATCHES_WD}/debian/patches/system/ffmpeg43.patch"
	"${UGC_PATCHES_WD}/debian/patches/system/jpeg.patch"
	"${UGC_PATCHES_WD}/debian/patches/system/nspr.patch"
	"${UGC_PATCHES_WD}/debian/patches/system/zlib.patch"
	"${UGC_PATCHES_WD}/debian/patches/system/openjpeg.patch"
	"${UGC_PATCHES_WD}/debian/patches/inox-patchset/fix-cfi-failures-with-unbundled-libxml.patch"
	"${UGC_PATCHES_WD}/debian/patches/ungoogled-chromium/clang.patch"
	"${UGC_PATCHES_WD}/debian/patches/ungoogled-chromium/manpage.patch"
	"${UGC_PATCHES_WD}/debian/patches/ungoogled-chromium/safebrowsing.patch"
	"${UGC_PATCHES_WD}/debian/patches/ungoogled-chromium/headers.patch"
	"${FILESDIR}/${PN}-gcc-10.patch"
	"${FILESDIR}/${PN}-lss.patch"
	"${FILESDIR}/${PN}-83-system-clang-format.patch"
	"${FILESDIR}/${PN}-libusb-interrupt-event-handler-r1.patch"
	"${FILESDIR}/${PN}-system-libusb-r0.patch"
	"${FILESDIR}/${PN}-system-fix-shim-headers-r0.patch"
)

S="${WORKDIR}/chromium-${PV/_*}"

pre_build_checks() {
	# Check build requirements (Bug #541816)
	CHECKREQS_MEMORY="3G"
	CHECKREQS_DISK_BUILD="7G"
	if use custom-cflags && ( shopt -s extglob; is-flagq '-g?(gdb)?([1-9])' ); then
		CHECKREQS_DISK_BUILD="25G"
	fi
	check-reqs_pkg_setup
}

pkg_pretend() {
	if use custom-cflags && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "USE=custom-cflags bypass strip-flags; you are on your own."
		ewarn "Expect build failures. Don't file bugs using that unsupported USE flag!"
		ewarn
	fi
	pre_build_checks
}

pkg_setup() {
	pre_build_checks
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	# Calling this here supports resumption via FEATURES=keepwork
	python_setup 'python3*'

	default

	if use vaapi ; then
		eapply "${UGC_PATCHES_WD}/debian/patches/fedora/vaapi.patch" || die
		eapply "${UGC_PATCHES_WD}/debian/patches/fedora/vaapi-fix.patch" || die
	fi

	if use "system-jsoncpp" ; then
		eapply "${UGC_PATCHES_WD}/debian/patches/system/jsoncpp.patch" || die
	fi

	if use "system-icu" ; then
		eapply "${UGC_PATCHES_WD}/debian/patches/system/icu.patch" || die
		eapply "${UGC_PATCHES_WD}/debian/patches/system/icu67.patch" || die
		eapply "${UGC_PATCHES_WD}/debian/patches/system/convertutf.patch" || die
		eapply "${FILESDIR}/${PN}-system-icu-r2.patch" || die
	fi

	if use "system-double-conversion" ; then
		eapply "${FILESDIR}/${PN}-system-double-conversion.patch" || die
	fi

	if use optimize-webui; then
		mkdir -p third_party/node/linux/node-linux-x64/bin || die
		ln -s "${EPREFIX}/usr/bin/node" \
			third_party/node/linux/node-linux-x64/bin/node || die
	fi

	# Hack for libusb stuff (taken from openSUSE)
	rm third_party/libusb/src/libusb/libusb.h || die
	cp -a "${EPREFIX}/usr/include/libusb-1.0/libusb.h" \
		third_party/libusb/src/libusb/libusb.h || die

	ebegin "Pruning binaries"
	if use closure-compile; then
		sed -i '\#third_party/closure_compiler/compiler/compiler.jar#d' "${UGC_WD}/pruning.list"
	fi
	"${UGC_WD}/utils/prune_binaries.py" . "${UGC_WD}/pruning.list"
	eend $? || die

	ebegin "Applying ungoogled-chromium patches"
	"${UGC_WD}/utils/patches.py" apply . "${UGC_WD}/patches"
	eend $? || die

	ebegin "Applying domain substitution"
	"${UGC_WD}/utils/domain_substitution.py" apply -r "${UGC_WD}/domain_regex.list" -f "${UGC_WD}/domain_substitution.list" -c build/domsubcache.tar.gz .
	eend $? || die

	local keeplibs=(
		base/third_party/cityhash
		base/third_party/dynamic_annotations
		base/third_party/icu
		base/third_party/superfasthash
		base/third_party/symbolize
		base/third_party/valgrind
		base/third_party/xdg_mime
		base/third_party/xdg_user_dirs
		chrome/third_party/mozilla_security_manager
		courgette/third_party
		net/third_party/mozilla_security_manager
		net/third_party/nss
		net/third_party/quic
		net/third_party/uri_template
		third_party/abseil-cpp
		third_party/angle
		third_party/angle/src/common/third_party/base
		third_party/angle/src/common/third_party/smhasher
		third_party/angle/src/common/third_party/xxhash
		third_party/angle/src/third_party/compiler
		third_party/angle/src/third_party/libXNVCtrl
		third_party/angle/src/third_party/trace_event
		third_party/angle/src/third_party/volk
		third_party/angle/third_party/glslang
		third_party/angle/third_party/spirv-headers
		third_party/angle/third_party/spirv-tools
		third_party/angle/third_party/vulkan-headers
		third_party/angle/third_party/vulkan-loader
		third_party/angle/third_party/vulkan-tools
		third_party/angle/third_party/vulkan-validation-layers
		third_party/adobe
		third_party/apple_apsl
		third_party/axe-core
		third_party/blink
		third_party/boringssl
		third_party/boringssl/src/third_party/fiat
		third_party/breakpad
		third_party/breakpad/breakpad/src/third_party/curl
		third_party/brotli
		third_party/cacheinvalidation
		third_party/catapult
		third_party/catapult/common/py_vulcanize/third_party/rcssmin
		third_party/catapult/common/py_vulcanize/third_party/rjsmin
		third_party/catapult/third_party/beautifulsoup4
		third_party/catapult/third_party/html5lib-python
		third_party/catapult/third_party/polymer
		third_party/catapult/third_party/six
		third_party/catapult/tracing/third_party/d3
		third_party/catapult/tracing/third_party/gl-matrix
		third_party/catapult/tracing/third_party/jpeg-js
		third_party/catapult/tracing/third_party/jszip
		third_party/catapult/tracing/third_party/mannwhitneyu
		third_party/catapult/tracing/third_party/oboe
		third_party/catapult/tracing/third_party/pako
		third_party/ced
		third_party/cld_3
		third_party/closure_compiler
		third_party/closure_compiler/compiler
		third_party/crashpad
		third_party/crashpad/crashpad/third_party/zlib
		third_party/crc32c
		third_party/cros_system_api
		third_party/dav1d
		third_party/dawn
		third_party/depot_tools
		third_party/devscripts
		third_party/devtools-frontend
		third_party/devtools-frontend/src/front_end/third_party/fabricjs
		third_party/devtools-frontend/src/front_end/third_party/lighthouse
		third_party/devtools-frontend/src/front_end/third_party/wasmparser
		third_party/devtools-frontend/src/third_party
		third_party/dom_distiller_js
		third_party/emoji-segmenter
		third_party/flatbuffers
		third_party/glslang
		third_party/google_input_tools
		third_party/google_input_tools/third_party/closure_library
		third_party/google_input_tools/third_party/closure_library/third_party/closure
		third_party/googletest
		third_party/harfbuzz-ng/utils
		third_party/hunspell
		third_party/iccjpeg
		third_party/inspector_protocol
		third_party/jinja2
		third_party/jstemplate
		third_party/khronos
		third_party/leveldatabase
		third_party/libXNVCtrl
		third_party/libaddressinput
		third_party/libaom
		third_party/libaom/source/libaom/third_party/vector
		third_party/libaom/source/libaom/third_party/x86inc
		third_party/libgifcodec
		third_party/libjingle
		third_party/libphonenumber
		third_party/libsecret
		third_party/libsrtp
		third_party/libsync
		third_party/libudev
		third_party/libusb
		third_party/libwebm
		third_party/libxml/chromium
		third_party/libyuv
		third_party/lss
		third_party/mako
		third_party/markupsafe
		third_party/mesa
		third_party/metrics_proto
		third_party/modp_b64
		third_party/nasm
		third_party/one_euro_filter
		third_party/openscreen
		third_party/openscreen/src/third_party/tinycbor/src/src
		third_party/ots
		third_party/perfetto
		third_party/pffft
		third_party/ply
		third_party/polymer
		third_party/private-join-and-compute
		third_party/protobuf
		third_party/protobuf/third_party/six
		third_party/pyjson5
		third_party/qcms
		third_party/rnnoise
		third_party/s2cellid
		third_party/schema_org
		third_party/simplejson
		third_party/skia
		third_party/skia/include/third_party/skcms
		third_party/skia/include/third_party/vulkan
		third_party/skia/third_party/skcms
		third_party/skia/third_party/vulkan
		third_party/smhasher
		third_party/speech-dispatcher
		third_party/spirv-headers
		third_party/SPIRV-Tools
		third_party/sqlite
		third_party/usb_ids
		third_party/usrsctp
		third_party/vulkan
		third_party/web-animations-js
		third_party/webdriver
		third_party/webrtc
		third_party/webrtc/common_audio/third_party/fft4g
		third_party/webrtc/common_audio/third_party/spl_sqrt_floor
		third_party/webrtc/modules/third_party/fft
		third_party/webrtc/modules/third_party/g711
		third_party/webrtc/modules/third_party/g722
		third_party/webrtc/rtc_base/third_party/base64
		third_party/webrtc/rtc_base/third_party/sigslot
		third_party/widevine
		third_party/woff2
		third_party/xdg-utils
		third_party/yasm/run_yasm.py
		third_party/zlib/google
		tools/grit/third_party/six
		url/third_party/mozilla
		v8/src/third_party/siphash
		v8/src/third_party/valgrind
		v8/src/third_party/utf8-decoder
		v8/third_party/inspector_protocol
		v8/third_party/v8
	)

	use optimize-webui && keeplibs+=(
		third_party/node
		third_party/node/node_modules/polymer-bundler/lib/third_party/UglifyJS2
	)
	use pdf && keeplibs+=(
		third_party/pdfium
		third_party/pdfium/third_party/agg23
		third_party/pdfium/third_party/base
		third_party/pdfium/third_party/bigint
		third_party/pdfium/third_party/freetype
		third_party/pdfium/third_party/lcms
		third_party/pdfium/third_party/libtiff
		third_party/pdfium/third_party/skia_shared
	)
	use system-openjpeg || keeplibs+=(
		third_party/pdfium/third_party/libopenjpeg20
	)
	use system-ffmpeg || keeplibs+=( third_party/ffmpeg third_party/opus )
	use system-harfbuzz || keeplibs+=(
		third_party/freetype
		build/config/freetype/freetype.gni
		third_party/harfbuzz-ng
	)
	use system-icu || keeplibs+=( third_party/icu )
	use system-jsoncpp || keeplibs+=( third_party/jsoncpp )
	use system-libevent || keeplibs+=( base/third_party/libevent )
	use system-libvpx || keeplibs+=(
		third_party/libvpx
		third_party/libvpx/source/libvpx/third_party/x86inc
	)
	use system-openh264 || keeplibs+=( third_party/openh264 )
	use tcmalloc && keeplibs+=( third_party/tcmalloc )

	python_setup 'python2*'

	# Remove most bundled libraries, some are still needed
	build/linux/unbundle/remove_bundled_libraries.py "${keeplibs[@]}" --do-remove || die
}

# Handle all CFLAGS/CXXFLAGS/etc... munging here.
setup_compile_flags() {
	# Avoid CFLAGS problems (Bug #352457, #390147)
	if ! use custom-cflags; then
		replace-flags "-Os" "-O2"
		strip-flags

		# Filter common/redundant flags. See build/config/compiler/BUILD.gn
		filter-flags -fomit-frame-pointer -fno-omit-frame-pointer \
			-fstack-protector* -fno-stack-protector* -fuse-ld=* -g* -Wl,*

		# Prevent libvpx build failures (Bug #530248, #544702, #546984)
		filter-flags -mno-mmx -mno-sse2 -mno-ssse3 -mno-sse4.1 -mno-avx -mno-avx2
	fi

	if use libcxx; then
		append-cxxflags "-stdlib=libc++"
		append-ldflags "-stdlib=libc++ -Wl,-lc++abi"
	else
		if has_version 'sys-devel/clang[default-libcxx]'; then
			append-cxxflags "-stdlib=libstdc++"
			append-ldflags "-stdlib=libstdc++"
		fi
	fi

	if use clang; then
		# 'gcc_s' is still required if 'compiler-rt' is Clang's default rtlib
		has_version 'sys-devel/clang[default-compiler-rt]' && \
			append-ldflags "-Wl,-lgcc_s"
	else
		append-cxxflags -fpermissive
	fi

	if use thinlto; then
		# We need to change the default value of import-instr-limit in
		# LLVM to limit the text size increase. The default value is
		# 100, and we change it to 30 to reduce the text size increase
		# from 25% to 10%. The performance number of page_cycler is the
		# same on two of the thinLTO configurations, we got 1% slowdown
		# on speedometer when changing import-instr-limit from 100 to 30.
		local thinlto_ldflag=( "-Wl,-plugin-opt,-import-instr-limit=30" )

		use gold && thinlto_ldflag+=(
			"-Wl,-plugin-opt=thinlto"
			"-Wl,-plugin-opt,jobs=$(makeopts_jobs)"
		)

		use lld && thinlto_ldflag+=( "-Wl,--thinlto-jobs=$(makeopts_jobs)" )

		append-ldflags "${thinlto_ldflag[*]}"
	else
		use gold && append-ldflags "-Wl,--threads -Wl,--thread-count=$(makeopts_jobs)"
	fi

	# Don't complain if Chromium uses a diagnostic option that is not yet
	# implemented in the compiler version used by the user. This is only
	# supported by Clang.
	append-flags -Wno-unknown-warning-option

	# Facilitate deterministic builds (taken from build/config/compiler/BUILD.gn)
	append-cflags -Wno-builtin-macro-redefined
	append-cxxflags -Wno-builtin-macro-redefined
	append-cppflags "-D__DATE__= -D__TIME__= -D__TIMESTAMP__="

	local flags
	einfo "Building with the compiler settings:"
	for flags in {C,CXX,CPP,LD}FLAGS; do
		einfo "  ${flags} = ${!flags}"
	done
}

src_configure() {
	# Make sure the build system will use the right tools (Bug #340795)
	tc-export AR CC CXX NM

	if use clang; then
		# Force clang
		CC=${CHOST}-clang
		CXX=${CHOST}-clang++
		AR=llvm-ar
		NM=llvm-nm
		strip-unsupported-flags
	fi

	local gn_system_libraries=(
		flac
		fontconfig
		freetype
		libdrm
		libjpeg
		libpng
		libusb
		libwebp
		libxml
		libxslt
		re2
		snappy
		yasm
		zlib
	)

	use system-ffmpeg && gn_system_libraries+=( ffmpeg opus )
	use system-harfbuzz && gn_system_libraries+=( freetype harfbuzz-ng )
	use system-icu && gn_system_libraries+=( icu )
	use system-libevent && gn_system_libraries+=( libevent )
	use system-libvpx && gn_system_libraries+=( libvpx )
	use system-openh264 && gn_system_libraries+=( openh264 )

	build/linux/unbundle/replace_gn_files.py --system-libraries "${gn_system_libraries[@]}" || die

	local myconf_gn=(
		# Clang features
		"is_cfi=$(usetf cfi)" # Implies use_cfi_icall=true
		"is_clang=$(usetf clang)"
		"clang_use_chrome_plugins=false"
		"thin_lto_enable_optimizations=$(usetf optimize-thinlto)"
		"use_lld=$(usetf lld)"
		"use_thin_lto=$(usetf thinlto)"

		# UGC's "common" GN flags (config_bundles/common/gn_flags.map)
		"blink_symbol_level=0"
		"closure_compile=$(usetf closure-compile)"
		"enable_hangout_services_extension=false"
		"enable_iterator_debugging=false"
		"enable_mdns=false"
		"enable_mse_mpeg2ts_stream_parser=true"
		"enable_nacl=false"
		"enable_nacl_nonsfi=false"
		"enable_one_click_signin=false"
		"enable_reading_list=false"
		"enable_remoting=false"
		"enable_reporting=false"
		"enable_service_discovery=false"
		"enable_swiftshader=false"
		"enable_widevine=$(usetf widevine)"
		"exclude_unwind_tables=true"
		"fatal_linker_warnings=false"
		"ffmpeg_branding=\"$(usex proprietary-codecs Chrome Chromium)\""
		"fieldtrial_testing_like_official_build=true"
		"google_api_key=\"\""
		"google_default_client_id=\"\""
		"google_default_client_secret=\"\""
		"is_debug=false"
		"is_official_build=true"
		"optimize_webui=$(usetf optimize-webui)"
		"proprietary_codecs=$(usetf proprietary-codecs)"
		"safe_browsing_mode=0"
		"symbol_level=0"
		"treat_warnings_as_errors=false"
		"use_gnome_keyring=false" # Deprecated by libsecret
		"use_jumbo_build=$(usetf jumbo-build)"
		"use_official_google_api_keys=false"
		"use_ozone=false"
		"use_sysroot=false"
		"use_unofficial_version_number=false"

		# UGC's "linux_rooted" GN flags (config_bundles/linux_rooted/gn_flags.map)
		"custom_toolchain=\"//build/toolchain/linux/unbundle:default\""
		"gold_path=\"\""
		"goma_dir=\"\""
		"host_toolchain=\"//build/toolchain/linux/unbundle:default\""
		"link_pulseaudio=$(usetf pulseaudio)"
		"linux_use_bundled_binutils=false"
		"use_allocator=\"$(usex tcmalloc tcmalloc none)\""
		"use_cups=$(usetf cups)"
		"use_custom_libcxx=false"
		"use_gio=$(usetf gnome)"
		"use_kerberos=$(usetf kerberos)"
		# If enabled, it will build the bundled OpenH264 for encoding,
		# hence the restriction: !system-openh264? ( bindist )
		"use_openh264=$(usetf !system-openh264)"
		"use_pulseaudio=$(usetf pulseaudio)"
		# HarfBuzz and FreeType need to be built together in a specific way
		# to get FreeType autohinting to work properly. Chromium bundles
		# FreeType and HarfBuzz to meet that need. (https://crbug.com/694137)
		"use_system_freetype=$(usetf system-harfbuzz)"
		"use_system_harfbuzz=$(usetf system-harfbuzz)"
		"use_system_lcms2=$(usetf pdf)"
		"use_system_libjpeg=true"
		"use_system_libopenjpeg2=$(usetf system-openjpeg)"
		"use_system_zlib=true"
		"use_vaapi=$(usetf vaapi)"

		# Additional flags
		"enable_pdf=$(usetf pdf)"
		"enable_print_preview=$(usetf pdf)"
		"rtc_build_examples=false"
		"use_icf=true"
	)

	# use_cfi_icall only works with LLD
	use cfi && myconf_gn+=( "use_cfi_icall=$(usetf lld)" )

	setup_compile_flags

	# Bug #491582
	export TMPDIR="${WORKDIR}/temp"
	# shellcheck disable=SC2174
	mkdir -p -m 755 "${TMPDIR}" || die

	# Bug #654216
	addpredict /dev/dri/ #nowarn

	# Chromium relies on this, but was disabled in >=clang-10, crbug.com/1042470
	append-cxxflags $(test-flags-CXX -flax-vector-conversions=all)

	einfo "Configuring Chromium..."
	set -- gn gen --args="${myconf_gn[*]} ${EXTRA_GN}" out/Release
	echo "$@"
	"$@" || die
}

src_compile() {
	# Final link uses lots of file descriptors
	ulimit -n 4096

	# shellcheck disable=SC2086
	# Avoid falling back to preprocessor mode when sources contain time macros
	has ccache ${FEATURES} && \
		export CCACHE_SLOPPINESS="${CCACHE_SLOPPINESS:-time_macros}"

	# Build mksnapshot and pax-mark it
	local x
	for x in mksnapshot v8_context_snapshot_generator; do
		if tc-is-cross-compiler; then
			eninja -C out/Release "host/${x}"
			pax-mark m "out/Release/host/${x}"
		else
			eninja -C out/Release "${x}"
			pax-mark m "out/Release/${x}"
		fi
	done

	# Even though ninja autodetects number of CPUs, we respect
	# user's options, for debugging with -j 1 or any other reason
	eninja -C out/Release chrome chromedriver
	use suid && eninja -C out/Release chrome_sandbox

	pax-mark m out/Release/chrome

	# Build manpage; bug #684550
	sed -e 's|@@PACKAGE@@|chromium-browser|g;
			s|@@MENUNAME@@|Chromium|g;' \
			chrome/app/resources/manpage.1.in > \
			out/Release/chromium-browser.1 || die

	# Build desktop file; bug #706786
	sed -e 's|@@MENUNAME@@|Chromium|g;
		s|@@USR_BIN_SYMLINK_NAME@@|chromium-browser|g;
		s|@@PACKAGE@@|chromium-browser|g;
		s|\(^Exec=\)/usr/bin/|\1|g;' \
		chrome/installer/linux/common/desktop.template > \
		out/Release/chromium-browser-chromium.desktop || die
}

src_install() {
	local CHROMIUM_HOME="/usr/$(get_libdir)/chromium-browser"
	exeinto "${CHROMIUM_HOME}"
	doexe out/Release/chrome

	if use suid; then
		newexe out/Release/chrome_sandbox chrome-sandbox
		fperms 4755 "${CHROMIUM_HOME}/chrome-sandbox"
	fi

	doexe out/Release/chromedriver

	local sedargs=( -e "s:/usr/lib/:/usr/$(get_libdir)/:g" )
	sed "${sedargs[@]}" "${FILESDIR}/${PN}-launcher-r3.sh" > chromium-launcher.sh || die
	doexe chromium-launcher.sh

	# It is important that we name the target "chromium-browser",
	# xdg-utils expect it (Bug #355517)
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium-browser
	# keep the old symlink around for consistency
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium

	dosym "${CHROMIUM_HOME}/chromedriver" /usr/bin/chromedriver

	# Allow users to override command-line options (Bug #357629)
	insinto /etc/chromium
	newins "${FILESDIR}/${PN}.default" "default"

	pushd out/Release/locales > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	insinto "${CHROMIUM_HOME}"
	doins out/Release/*.bin
	doins out/Release/*.pak
	doins out/Release/*.so

	use system-icu || doins out/Release/icudtl.dat

	doins -r out/Release/locales
	doins -r out/Release/resources

	if [[ -d out/Release/swiftshader ]]; then
		insinto "${CHROMIUM_HOME}/swiftshader"
		doins out/Release/swiftshader/*.so
	fi

	# Install icons and desktop entry
	local branding size
	for size in 16 24 32 48 64 128 256; do
		case ${size} in
			16|32) branding="chrome/app/theme/default_100_percent/chromium" ;;
				*) branding="chrome/app/theme/chromium" ;;
		esac
		newicon -s ${size} "${branding}/product_logo_${size}.png" chromium-browser.png
	done

	# Install desktop entry
	domenu out/Release/chromium-browser-chromium.desktop

	# Install GNOME default application entry (Bug #303100)
	insinto /usr/share/gnome-control-center/default-apps
	newins "${FILESDIR}"/chromium-browser.xml chromium-browser.xml

	# Install manpage; bug #684550
	doman out/Release/chromium-browser.1
	dosym chromium-browser.1 /usr/share/man/man1/chromium.1

	readme.gentoo_create_doc
}

usetf() {
	usex "$1" true false
}

update_caches() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	update_caches
}

pkg_postinst() {
	update_caches
	readme.gentoo_print_elog
}