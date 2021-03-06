# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the WFTPL version 2
# $Header: $

EAPI=5

inherit games autotools

DESCRIPTION="ePSXe Playstation Emulator"
HOMEPAGE="http://www.epsxe.com"
SRC_URI="http://www.epsxe.com/files/epsxe1925lin.zip
menu? ( http://www.epsxe.com/files/ePSXe1925.zip )
bios? ( https://drive.google.com/uc?export=download&id=0BzPt9N2PyrQGenh0MGxCa1pxejQ -> playstation-bios.tar.xz )
xgl2? (
	http://www.pbernert.com/gpupetexgl209.tar.gz
	bin? ( http://www.pbernert.com/petegpucfg_V2-9_V1-77_V1-18.tar.gz )
	!bin? ( http://www.pbernert.com/gpu_xgl2_cfg_2_08.tar.gz )
)
mesa? (
	bin? ( http://www.pbernert.com/gpupeopsmesagl178.tar.gz )
	!bin? ( http://www.pbernert.com/PeopsOpenGLGpu178Sources.zip )
)
softgpu? (
	bin? (
		http://www.pbernert.com/gpupeopssoftx118.tar.gz
		http://www.pbernert.com/petegpucfg_V2-9_V1-77_V1-18.tar.gz
	)
	!bin? (
		http://downloads.sourceforge.net/project/peops/peopssoftgpu/P.E.Op.S.%20Soft%20GPU%201.18/PeopsSoftGpu118.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fpeops%2Ffiles%2Fpeopssoftgpu%2FP.E.Op.S.%2520Soft%2520GPU%25201.18%2F&ts=1435692248&use_mirror=iweb -> PeopsSoftGPU118.zip
	)
)
oss? (
	bin? ( http://www.pbernert.com/spupeopsoss109.tar.gz )
	!bin? ( http://downloads.sourceforge.net/project/peops/peopsspu/P.E.Op.S.%20Sound%20SPU%201.9/PeopsSpu109.tar.gz )
)
nullspu? ( http://www.pbernert.com/spupetenull101.tar.gz )
alsa? ( http://downloads.sourceforge.net/project/peops/peopsspu/P.E.Op.S.%20Sound%20SPU%201.9/PeopsSpu109.tar.gz )
pulseaudio? ( http://downloads.sourceforge.net/project/peops/peopsspu/P.E.Op.S.%20Sound%20SPU%201.9/PeopsSpu109.tar.gz )
"

LICENSE="epsxe"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="doc bios xgl2 +mesa +softgpu config-ui oss +menu nullspu alsa pulseaudio bin"
RESTRICT="mirror"

DEPEND="
	app-arch/unzip
	sys-apps/sed
	sys-devel/make
	app-text/dos2unix
	>=app-arch/upx-ucl-3.0
	softgpu? ( !bin? ( dev-lang/nasm ) )
	menu? ( media-gfx/icoutils )
"
RDEPEND="${DEPEND}
	sys-libs/ncurses:5[abi_x86_32,tinfo]
	>=sys-libs/zlib-1.2.8[abi_x86_32]
	>=x11-libs/libX11-1.6.0[abi_x86_32]
	>=media-libs/alsa-lib-1.0.29[abi_x86_32]
	x11-libs/gtk+:2[abi_x86_32]
	>=media-libs/sdl-ttf-2.0.0[abi_x86_32]
	media-libs/mesa[abi_x86_32]
	config-ui? ( xgl2? ( bin? ( x11-libs/gtk+:1[abi_x86_32] ) ) )
	config-ui? ( mesa? ( bin? ( x11-libs/gtk+:1[abi_x86_32] ) ) )
	config-ui? ( oss? ( bin? ( x11-libs/gtk+:1[abi_x86_32] ) ) )
	config-ui? ( alsa? ( bin? (  x11-libs/gtk+:1[abi_x86_32] ) ) )
	config-ui? ( pulseaudio? ( bin? ( x11-libs/gtk+:1[abi_x86_32] ) ) )
"

src_unpack()
{
	# unpack epsxe
	mkdir -p "${S}" || die "Unpack failed!"
	unzip -x "${DISTDIR}/epsxe1925lin.zip" -d "${S}" >/dev/null || die "Unpack failed!"

	use bios && tar -xf "${DISTDIR}/playstation-bios.tar.xz" -C "${S}"

	if use xgl2; then
		tar -xf "${DISTDIR}/gpupetexgl209.tar.gz" -C "${S}" || die "Unpack failed!"
		if ! (use bin); then
			tar -xf "${DISTDIR}/gpu_xgl2_cfg_2_08.tar.gz" -C "${S}" || die "Unpack failed!"
		fi
	fi

	# unpack mesagl driver
	if use mesa; then
		if use bin; then
			tar -xf "${DISTDIR}/gpupeopsmesagl178.tar.gz" -C "${S}"
		else
			mkdir -p "${S}/mesagl"
			unzip -x "${DISTDIR}/PeopsOpenGLGpu178Sources.zip" -d "${S}/mesagl" > /dev/null
			tar -xf "${S}/mesagl/src/src_linux_cfg/gpucfg.tar.gz" \
				-C "${S}/mesagl/src/src_linux_cfg"
		fi
	fi

	# unpacck SoftX driver
	if use softgpu; then
		if use bin; then
			tar -xf "${DISTDIR}/gpupeopssoftx118.tar.gz" -C "${S}"
		else
			unzip -q -x "${DISTDIR}/PeopsSoftGPU118.zip" -d "${S}"
		fi
	fi

	if (use config-ui && use bin && (use xgl2 || use softgpu)); then
		mkdir -p "${S}/cfg-files"
		tar -xf "${DISTDIR}/petegpucfg_V2-9_V1-77_V1-18.tar.gz" -C "${S}/cfg-files"
	fi

	# unpack oss driver
	if use oss; then
		if use bin; then
			tar -xf "${DISTDIR}/spupeopsoss109.tar.gz" -C "${S}"
		else
			mkdir -p "${S}/oss"
			tar -xf "${DISTDIR}/PeopsSpu109.tar.gz" -C "${S}/oss"
			if use config-ui; then
				tar -xf "${S}/oss/src/linuxcfg/spucfg.tar.gz" -C "${S}/oss/src/linuxcfg"
			fi
		fi
	fi
	use nullspu && tar -xf "${DISTDIR}/spupetenull101.tar.gz" -C "${S}"

	# unpack alsa driver
	if use alsa; then
		mkdir -p "${S}/alsa"
		tar -xf "${DISTDIR}/PeopsSpu109.tar.gz" -C "${S}/alsa"
		if use config-ui; then
			tar -xf "${S}/alsa/src/linuxcfg/spucfg.tar.gz" -C "${S}/alsa/src/linuxcfg"
		fi
	fi

	# unpack pulseaudio driver
	if use pulseaudio; then
		mkdir -p "${S}/pulse"
		tar -xf "${DISTDIR}/PeopsSpu109.tar.gz" -C "${S}/pulse"
		if use config-ui; then
			tar -xf "${S}/pulse/src/linuxcfg/spucfg.tar.gz" -C "${S}/pulse/src/linuxcfg"
		fi
	fi

	# unpack epsxe for windows (to extract icon)
	if use menu; then
		mkdir -p "${S}/w32" || die "Unpack failed!"
		unzip -x "${DISTDIR}/ePSXe1925.zip" -d "${S}/w32" > /dev/null || die "Unpack failed!"
	fi
}

do_fix_line_endings()
{
	einfo "Fixing line ending in ${1}"
	cd "${1}"
	for f in $(ls); do
		if [ -f "${f}" ]; then
			dos2unix -q "${f}"
		elif [ -d "${f}" ]; then
			do_fix_line_endings "${f}"
		fi
	done
}

do_patch_spu_plugin()
{
	# change plugin name
	cp "${1}/src/spu.c" "${1}/src/spu.c.orig"
	sed -e "s/P.E.Op.S. ALSA Audio Driver/P.E.Op.S. ${3} Audio Driver/g" \
		"${1}/src/spu.c.orig" > "${1}/src/spu.c"

	# change config file and dialog executable name
	cp "${1}/spuPeopsOSS.cfg" "${1}/spuPeops${2}.cfg"
	cp "${1}/src/cfg.c" "${1}/src/cfg.c.orig"
	sed -e "s/spuPeopsOSS.cfg/spuPeops${2}.cfg/g" \
		"${1}/src/cfg.c.orig" | \
	sed -e "s/cfgPeopsOSS/cfgPeops${2}/g" > \
		"${1}/src/cfg.c"

	if use config-ui; then
		# Fix line endings
		do_fix_line_endings "${1}/src/linuxcfg"
		do_fix_line_endings "${1}/src/linuxcfg/src"

		# use gtk+2 patch
		cd "${1}/src/linuxcfg"
		epatch "${FILESDIR}/PeopsSpu109-linuxcfg-gtk.patch"

		# change dialog title
		cp "${1}/src/linuxcfg/src/interface.c" "${1}/src/linuxcfg/src/interface.c.orig"
		sed -e "s/Configure P.E.Op.S. OSS PSX SPU plugin/Configure P.E.Op.S. ${2} PSX SPU plugin/g" \
			"${1}/src/linuxcfg/src/interface.c.orig" > \
			"${1}/src/linuxcfg/src/interface.c"

		# change hardcoded config file
		cp "${1}/src/linuxcfg/src/main.c" "${1}/src/linuxcfg/src/main.c.orig"
		sed -e "s/spuPeopsOSS.cfg/spuPeops${2}.cfg/g" \
			"${1}/src/linuxcfg/src/main.c.orig" > \
			"${1}/src/linuxcfg/src/main.c"

		cd "${1}/src/linuxcfg"
		einfo "Regenerating autotools files."
		eautoconf
		eautomake
	fi
}

src_prepare()
{
	# unupx it
	einfo "Unpacking ePSXe executable..."
	mv "${S}/epsxe" "${S}/epsxe.bak"
	upx -q -d -o "${S}/epsxe" "${S}/epsxe.bak"
	rm "${S}/epsxe.bak"

	# fix bios filenames
	if use bios; then
		einfo "Fixing PlayStation bios filenames..."
		cp "${S}/SCPH1000.BIN"  "${S}/scph1000.bin"
		cp "${S}/SCPH1001.bin"  "${S}/scph1001.bin"
		cp "${S}/SCPH5000.BIN"  "${S}/scph5000.bin"
		cp "${S}/SCPH5500.BIN"  "${S}/scph5500.bin"
		cp "${S}/SCPH7001.BIN"  "${S}/scph7001.bin"
		cp "${S}/SCPH7502.BIN"  "${S}/scph7502.bin"
	fi

	if (use softgpu && (! use bin)); then
		do_fix_line_endings "${S}/gpuPeopsSoft/src"

		cd "${S}/gpuPeopsSoft"
		epatch "${FILESDIR}/PeopsSoftGPU118-gtk.patch"

		cd "${S}/gpuPeopsSoft/src"
		for f in $(ls); do
			if [ -f "${f}" ]; then
				mv "${f}" "${f}.orig"
				sed -e "s/BOOL/BOOLeAN/g" "${f}.orig" > "${f}"
				rm "${f}.orig"
			fi
		done
		mv "${S}/gpuPeopsSoft/src/draw.c" "${S}/gpuPeopsSoft/src/draw.c.orig" || \
			die "Prepare failed!"
		sed -e "s/\*((unsigned long\*)pDst)++/((unsigned long\*)pDst)[x]/g" \
			"${S}/gpuPeopsSoft/src/draw.c.orig" > "${S}/gpuPeopsSoft/src/draw.c" || \
			die "Prepare failed!"

		mv "${S}/gpuPeopsSoft/src/makes/plg.mk" "${S}/gpuPeopsSoft/src/makes/plg.mk.orig"
		sed -e "s/INCLUDE = -I\/usr\/local\/include//g" "${S}/gpuPeopsSoft/src/makes/plg.mk.orig" | \
		sed -e "s/-g -Wall -fPIC -O4 -fomit-frame-pointer -ffast-math \$(INCLUDE)/-g -fPIC -ffast-math ${CFLAGS}/g" > \
			"${S}/gpuPeopsSoft/src/makes/plg.mk" || die "Prepare failed!"

		mv "${S}/gpuPeopsSoft/src/makes/mk.x11" "${S}/gpuPeopsSoft/src/makes/mk.x11.orig" || \
			die "Prepare failed!"
		sed -e "s/LIBS += -L\/usr\/X11\/lib//g" "${S}/gpuPeopsSoft/src/makes/mk.x11.orig" | \
		sed -e "s/OBJECTS+= \/usr\/X11R6\/lib\/libXxf86vm.a/LIBS+=-lXxf86vm/g" | \
		sed -e "s/CFGOBJS+= \/usr\/X11R6\/lib\/libXxf86vm.a/CFGLIBS+=-lXxf86vm/g" > "${S}/gpuPeopsSoft/src/makes/mk.x11" || \
			die "Prepare failed!"

		mv "${S}/gpuPeopsSoft/src/cfg.c" "${S}/gpuPeopsSoft/src/cfg.c.orig"
		sed -e "s/sprintf(cfg, \"%s %s\", cfg, arg)/sprintf(cfg, \".\/cfg\/cfgPeopsSoft %s\", arg)/g" \
			"${S}/gpuPeopsSoft/src/cfg.c.orig" > "${S}/gpuPeopsSoft/src/cfg.c" || \
			die "Prepare failed!"

	fi

	if (use xgl2 && ! (use bin)); then
		if use config-ui; then
			einfo "Preparing XGL2 GPU plugin configuration utility..."
			do_fix_line_endings "${S}/gpucfg2"
			do_fix_line_endings "${S}/gpucfg2/src"
			cd "${S}/gpucfg2"
			epatch "${FILESDIR}/PeteXGL209-cfg-gtk.patch"
			eautoconf
			eautomake
		fi
	fi

	# patch and configure the mesagl driver
	if (use mesa && ! (use bin)); then
		einfo "Preparing MesaGL plugin source..."
		do_fix_line_endings "${S}/mesagl/src/src_plugin"
		mv "${S}/mesagl/src/src_plugin/GL_EXT.H" "${S}/mesagl/src/src_plugin/gl_ext.h"
		cd "${S}/mesagl/src/src_plugin"
		for f in $(ls); do
			if [ -f "${f}" ]; then
				mv "${f}" "${f}.orig"
				sed -e "s/BOOL/BOOLeAN/g" "${f}.orig" > "${f}"
				rm "${f}.orig"
			fi
		done
		mv Makefile Makefile.orig
		sed -e "s/\/usr\/X11R6\/lib\/libXxf86vm.a//g" Makefile.orig | \
		sed -e "s/-Wall -m32 -mcpu=pentium -O3 -ffast-math -fomit-frame-pointer/-m32 -ffast-math ${CFLAGS}/g" | \
		sed -e "s/-lpthread/-lpthread -lXxf86vm/g" > Makefile

		if use config-ui; then
			einfo "Preparing MesaGL plugin configuration utility source..."
			do_fix_line_endings "${S}/mesagl/src/src_linux_cfg/gpucfg"
			do_fix_line_endings "${S}/mesagl/src/src_linux_cfg/gpucfg/src"
			cd "${S}/mesagl/src/src_linux_cfg/gpucfg"
			epatch "${FILESDIR}/PeopsOpenGLGpu178-gtk.patch"
			eautoconf
			eautomake
		fi
	fi

	# fix readme filenames
	if use oss; then
		if use bin; then
			cp "${S}/readme_1_9.txt" "${S}/spuPeopsOSS_readme_1_9.txt"
		else
			einfo "Preparing OSS SPU plugin source..."
			cp "${S}/oss/readme_1_9.txt" "${S}/oss/spuPeopsOSS_readme_1_9.txt"
			cp "${S}/oss/src/Makefile" "${S}/oss/src/Makefile.orig"
			sed -e "s/-fPIC/-fPIC -m32/g" "${S}/oss/src/Makefile.orig" | \
			sed -e "s/-Wall -mpentium -O3 -ffast-math -fomit-frame-pointer/${CFLAGS}/g" | \
			sed -e "s/LINKFLAGS = /LINKFLAGS = -m32 /g" > "${S}/oss/src/Makefile"
			if use config-ui; then
				do_fix_line_endings "${S}/oss/src/linuxcfg"
				do_fix_line_endings "${S}/oss/src/linuxcfg/src"
				cd "${S}/oss/src/linuxcfg"
				epatch "${FILESDIR}/PeopsSpu109-linuxcfg-gtk.patch"

				einfo "Regenerating autotools files."
				eautoconf
				eautomake
			fi
		fi
	fi
	if use nullspu; then
		cp "${S}/readme.txt" "${S}/spuPeteNull_readme.txt"
	fi

	if use alsa; then
		einfo "Preparing ALSA SPU plugin source..."
		cp "${S}/alsa/src/Makefile" "${S}/alsa/src/Makefile.orig"
		sed -e "s/USEALSA = FALSE/USEALSA = TRUE/g" "${S}/alsa/src/Makefile.orig" | \
		sed -e "s/-fPIC/-fPIC -m32/g" | \
		sed -e "s/-Wall -mpentium -O3 -ffast-math -fomit-frame-pointer/${CFLAGS}/g" | \
		sed -e "s/LINKFLAGS = /LINKFLAGS = -m32 /g" > "${S}/alsa/src/Makefile"
		do_patch_spu_plugin "${S}/alsa" "ALSA" "ALSA"
	fi

	if use pulseaudio; then
		einfo "Preparing PulseAudio SPU plugin source..."
		cp "${S}/pulse/src/Makefile" "${S}/pulse/src/Makefile.orig"
		sed -e "s/USEALSA = FALSE/USEALSA = TRUE/g" "${S}/pulse/src/Makefile.orig" | \
		sed -e "s/-fPIC/-fPIC -m32/g" | \
		sed -e "s/-Wall -mpentium -O3 -ffast-math -fomit-frame-pointer/${CFLAGS}/g" | \
		sed -e "s/libspuPeopsALSA.so/libspuPeopsPA.so/g" | \
		sed -e "s/LINKFLAGS = /LINKFLAGS = -m32 /g" > "${S}/pulse/src/Makefile"

		# patch to use pulseaudio
		cp "${S}/pulse/src/alsa.c" "${S}/pulse/src/alsa.c.orig"
		sed -e "s/default/pulse/g" "${S}/pulse/src/alsa.c.orig" > "${S}/pulse/src/alsa.c"
		do_patch_spu_plugin "${S}/pulse" "PA" "PulseAudio"
	fi

	# extract windows icon
	if use menu; then
		wrestool -x -t 14 "${S}/w32/ePSXe.exe" > "${S}/epsxe.ico"
	fi
}

src_configure()
{
	if (use xgl2 && (! (use bin))); then
		if use config-ui; then
			einfo "Configuring XGL2 plugin configuration utility..."
			cd "${S}/gpucfg2"
			econf CFLAGS="-m32 ${CFLAGS}"
		fi
	fi
	if (use mesa && (! (use bin))); then
		if use config-ui; then
			einfo "Configuring MesaGL plugin configuration utility..."
			cd "${S}/mesagl/src/src_linux_cfg/gpucfg"
			econf CFLAGS="-m32 ${CFLAGS}"
		fi
	fi
	if (use oss && (! (use bin))); then
		if use config-ui; then
			einfo "Configuring OSS SPU plugin configuration utility..."
			cd "${S}/oss/src/linuxcfg"
			econf CFLAGS="-m32 ${CFLAGS}"
		fi
	fi
	if (use alsa && use config-ui); then
		einfo "Configuring ALSA SPU plugin configuration utility..."
		cd "${S}/alsa/src/linuxcfg"
		econf CFLAGS="-m32 ${CFLAGS}"
	fi
	if (use pulseaudio && use config-ui); then
		einfo "Configuring PulseAudio SPU plugin configuration utility..."
		cd "${S}/pulse/src/linuxcfg"
		econf CFLAGS="-m32 ${CFLAGS}"
	fi
}

src_compile()
{
	if (use softgpu && (! use bin)); then
		einfo "Compiling SoftX GPU plugin..."
		cd "${S}/gpuPeopsSoft/src"
		emake
	fi
	if (use xgl2 && (! (use bin))); then
		if use config-ui; then
			einfo "Compiling XGL2 GPU plugin configuration utility..."
			cd "${S}/gpucfg2"
			emake
			mv "${S}/gpucfg2/src/gpucfg" "${S}/gpucfg2/src/cfgPeteXGL2" || \
				die "Compile failed!"
		fi
	fi
	if (use mesa && (! (use bin))); then
		einfo "Compiling MesaGL GPU plugin..."
		cd "${S}/mesagl/src/src_plugin"
		emake
		if use config-ui; then
			einfo "Compiling MesaGL GPU configuration utility..."
			cd "${S}/mesagl/src/src_linux_cfg/gpucfg"
			emake
			cp "${S}/mesagl/src/src_linux_cfg/gpucfg/src/gpucfg" \
				"${S}/mesagl/src/src_linux_cfg/gpucfg/src/cfgPeopsMesaGL" || \
				die "Compile failed!"
		fi
	fi
	if (use oss && (! (use bin))); then
		einfo "Compiling OSS SPU plugin..."
		cd "${S}/oss/src"
		emake
		if use config-ui; then
			einfo "Compiling OSS SPU plugin configuration utility..."
			cd "${S}/oss/src/linuxcfg"
			emake
			cp "${S}/oss/src/linuxcfg/src/spucfg" \
				"${S}/oss/src/linuxcfg/src/cfgPeopsOSS" || die "Compile failed!"
		fi
	fi
	if use alsa; then
		einfo "Compiling ALSA SPU plugin..."
		cd "${S}/alsa/src"
		emake
		if use config-ui; then
			einfo "Compiling ALSA SPU plugin configuration utility..."
			cd "${S}/alsa/src/linuxcfg"
			emake
			cp "${S}/alsa/src/linuxcfg/src/spucfg" \
				"${S}/alsa/src/linuxcfg/src/cfgPeopsALSA" || die "Compile failed!"
		fi
	fi
	if use pulseaudio; then
		einfo "Compiling PulseAudio SPU plugin..."
		cd "${S}/pulse/src"
		emake
		if use config-ui; then
			einfo "Compiling PulseAudio SPU plugin configuration utility..."
			cd "${S}/pulse/src/linuxcfg"
			emake
			cp "${S}/pulse/src/linuxcfg/src/spucfg" \
				"${S}/pulse/src/linuxcfg/src/cfgPeopsPA" || die "Compile failed!"
		fi
	fi
}

src_install()
{
	MERGEDIR="/opt/epsxe"
	INSTALLDIR="${D}/${MERGEDIR}"

	diropts --owner=root --group=root
	dodir "${MERGEDIR}"
	dodir "${MERGEDIR}/bios"
	dodir "${MERGEDIR}/plugins"
	dodir "${MERGEDIR}/cfg"
	dodir "${MERGEDIR}/config"

	if use doc; then
		dodir "${MERGEDIR}/docs"
		insinto "${MERGEDIR}/docs"
		insopts --owner=root --group=root --mode=644
		doins "${S}/docs/ePSXe_en.txt"
		doins "${S}/docs/epsxe_linux_en.txt"
		doins "${S}/docs/ePSXe_sp.txt"
		doins "${S}/docs/epsxe_linux_sp.txt"
	fi

	dodir /usr/share/epsxe
	diropts --owner=root --group=games --mode=775
	dodir /var/epsxe/memcards
	dodir /var/epsxe/memcards/games
	dodir /var/epsxe/isos
	dodir /var/epsxe/patches
	dodir /var/epsxe/snap
	dodir /var/epsxe/sstates
	dodir /var/epsxe/idx
	dodir /var/epsxe/cheats

	dosym /var/epsxe/memcards "${MERGEDIR}/memcards"
	dosym /var/epsxe/isos "${MERGEDIR}/isos"
	dosym /var/epsxe/patches "${MERGEDIR}/patches"
	dosym /var/epsxe/snap "${MERGEDIR}/snap"
	dosym /var/epsxe/sstates "${MERGEDIR}/sstates"
	dosym /var/epsxe/idx "${MERGEDIR}/idx"
	dosym /var/epsxe/cheats "${MERGEDIR}/cheats"

	touch epsxerc
	dodir /etc/epsxe
	insopts --owner=root --group=games --mode=664
	insinto /etc/epsxe
	doins epsxerc
	dosym /etc/epsxe/epsxerc "${MERGEDIR}/.epsxerc"

	insinto "${MERGEDIR}"
	insopts --owner=root --group=root --mode=755
	doins "${S}/epsxe"
	insopts --owner=root --group=root --mode=644
	doins "${S}/keycodes.lst"

	if use doc; then
		insopts --owner=root --group=root --mode=644
		insinto "${MERGEDIR}/bios"
		doins "${S}/bios/erase.me"
		insinto "${MERGEDIR}/cfg"
		doins "${S}/cfg/erase.me"
		insinto "${MERGEDIR}/config"
		doins "${S}/config/erase.me"
		insinto /var/epsxe/idx
		doins "${S}/idx/kill.me"
		insinto /var/epsxe/isos
		doins "${S}/isos/kill.me"
		insinto /var/epsxe/memcards
		doins "${S}/memcards/delete.me"
		insinto /var/epsxe/memcards/games
		doins "${S}/memcards/games/delete.me"
		insinto /var/epsxe/patches
		doins "${S}/patches/kill.me"
		insinto "${MERGEDIR}/plugins"
		doins "${S}/plugins/remove.me"
		insinto /var/epsxe/snap
		doins "${S}/snap/kill.me"
		insinto /var/epsxe/sstates
		doins "${S}/sstates/kill.me"
		doins "${S}/sstates/punch.me"
	fi

	if use bios; then
		rm -f "${INSTALLDIR}/bios/erase.me"
		insinto "${MERGEDIR}/bios"
		insopts --owner=root --mode=root --mode=644
		doins "${S}/scph1000.bin"
		doins "${S}/scph1001.bin"
		doins "${S}/scph1002.bin"
		doins "${S}/scph5000a.bin"
		doins "${S}/scph5000.bin"
		doins "${S}/scph5500.bin"
		doins "${S}/scph5502.bin"
		doins "${S}/scph7001.bin"
		doins "${S}/scph7003.bin"
	fi

	if use xgl2; then
		rm -f "${INSTALLDIR}/plugins/remove.me"
		rm -f "${INSTALLDIR}/cfg/erase.me"
		insopts --owner=root --group=root --mode=644
		insinto "${MERGEDIR}/plugins"
		doins "${S}/libgpuPeteXGL2.so.2.0.9"
		insopts --owner=root --group=games --mode=664
		insinto /etc/epsxe
		doins "${S}/gpuPeteXGL2.cfg"
		dosym /etc/epsxe/gpuPeteXGL2.cfg "${MERGEDIR}/cfg/gpuPeteXGL2.cfg"
		if use config-ui; then
			if use bin; then
				insopts --owner=root --group=games --mode=750
				insinto "${MERGEDIR}/cfg"
				doins "${S}/cfg-files/cfg/cfgPeteXGL2"
			else
				insopts --owner=root --group=games --mode=750
				insinto "${MERGEDIR}/cfg"
				doins "${S}/gpucfg2/src/cfgPeteXGL2"
			fi
		fi
	fi

	if use mesa; then
		rm -f "${INSTALLDIR}/plugins/remove.me"
		rm -f "${INSTALLDIR}/cfg/erase.me"
		if use bin; then
			insopts --owner=root --group=root --mode=644
			insinto "${MERGEDIR}/plugins"
			doins "${S}/peops_psx_mesagl_gpu/libgpuPeopsMesaGL.so.1.0.78"
			insopts --owner=root --group=games --mode=664
			insinto /etc/epsxe
			doins "${S}/peops_psx_mesagl_gpu/gpuPeopsMesaGL.cfg"
			dosym /etc/epsxe/gpuPeopsMesaGL.cfg "${MERGEDIR}/cfg/gpuPeopsMesaGL.cfg"
			if use config-ui; then
				insopts --owner=root --group=games --mode=750
				insinto "${MERGEDIR}/cfg"
				doins "${S}/peops_psx_mesagl_gpu/cfgPeopsMesaGL"
			fi
		else
			insopts --owner=root --group=root --mode=644
			insinto "${MERGEDIR}/plugins"
			doins "${S}/mesagl/src/src_plugin/libgpuPeopsMesaGL.so.1.0.78"
			touch gpuPeopsMesaGL.cfg
			insopts --owner=root --group=games --mode=664
			insinto /etc/epsxe
			doins gpuPeopsMesaGL.cfg
			dosym /etc/epsxe/gpuPeopsMesaGL.cfg "${MERGEDIR}/cfg/gpuPeopsMesaGL.cfg"
			if use config-ui; then
				insopts --owner=root --group=games --mode=750
				insinto "${MERGEDIR}/cfg"
				doins "${S}/mesagl/src/src_linux_cfg/gpucfg/src/cfgPeopsMesaGL"
			fi
		fi
	fi

	if use softgpu; then
		rm -f "${INSTALLDIR}/plugins/remove.me"
		rm -f "${INSTALLDIR}/cfg/erase.me"
		if use bin; then
			insopts --owner=root --group=root --mode=644
			insinto "${MERGEDIR}/plugins"
			doins "${S}/libgpuPeopsSoftX.so.1.0.18"
			insopts --owner=root --group=games --mode=664
			insinto /etc/epsxe
			doins "${S}/gpuPeopsSoftX.cfg"
			dosym /etc/epsxe/gpuPeopsSoftX.cfg "${MERGEDIR}/cfg/gpuPeopsSoftX.cfg"
			if use config-ui; then
				insopts --owner=root --group=games --mode=750
				insinto "${MERGEDIR}/cfg"
				doins "${S}/cfg-files/cfg/cfgPeopsSoft"
			fi
			if use doc; then
				insopts --owner=root --group=root --mode=644
				insinto "${MERGEDIR}/docs"
				doins "${S}/peops_soft_readme_1_18.txt"
			fi
		else
			insopts --owner=root --group=root --mode=644
			insinto "${MERGEDIR}/plugins"
			doins "${S}/gpuPeopsSoft/src/libgpuPeopsSoftX.so.1.0.18"
			insopts --owner=root --group=games --mode=664
			insinto /etc/epsxe
			doins "${S}/gpuPeopsSoft/gpuPeopsSoftX.cfg"
			dosym /etc/epsxe/gpuPeopsSoftX.cfg "${MERGEDIR}/cfg/gpuPeopsSoftX.cfg"
			if use config-ui; then
				insopts --owner=root --group=games --mode=750
				insinto "${MERGEDIR}/cfg"
				doins "${S}/gpuPeopsSoft/src/cfgPeopsSoft"
			fi
		fi
	fi

	if use oss; then
		rm -f "${INSTALLDIR}/plugins/remove.me"
		rm -f "${INSTALLDIR}/cfg/erase.me"
		if use bin; then
			insopts --owner=root --group=root --mode=644
			insinto "${MERGEDIR}/plugins"
			doins "${S}/libspuPeopsOSS.so.1.0.9"
			insopts --owner=root --group=games --mode=664
			insinto /etc/epsxe
			doins "${S}/spuPeopsOSS.cfg"
			dosym /etc/epsxe/spuPeopsOSS.cfg "${MERGEDIR}/cfg/spuPeopsOSS.cfg"
			if use config-ui; then
				insopts --owner=root --group=games --mode=750
				insinto "${MERGEDIR}/cfg"
				doins "${S}/cfgPeopsOSS"
			fi
			if use doc; then
				insopts --owner=root --group=root --mode=644
				insinto "${MERGEDIR}/docs"
				doins "${S}/spuPeopsOSS_readme_1_9.txt"
			fi
		else
			insopts --owner=root --group=root --mode=644
			insinto "${MERGEDIR}/plugins"
			doins "${S}/oss/src/libspuPeopsOSS.so.1.0.9"
			insopts --owner=root --group=games --mode=664
			insinto /etc/epsxe
			doins "${S}/oss/spuPeopsOSS.cfg"
			dosym /etc/epsxe/spuPeopsOSS.cfg "${MERGEDIR}/cfg/spuPeopsOSS.cfg"
			if use config-ui; then
				insopts --owner=root --group=games --mode=750
				insinto "${MERGEDIR}/cfg"
				doins "${S}/oss/src/linuxcfg/src/cfgPeopsOSS"
			fi
			if use doc; then
				insopts --owner=root --group=root --mode=644
				insinto "${MERGEDIR}/docs"
				doins "${S}/oss/spuPeopsOSS_readme_1_9.txt"
			fi
		fi
	fi

	if use alsa; then
		rm -f "${INSTALLDIR}/plugins/remove.me"
		rm -f "${INSTALLDIR}/cfg/erase.me"
		insopts --owner=root --group=root --mode=644
		insinto "${MERGEDIR}/plugins"
		doins "${S}/alsa/src/libspuPeopsALSA.so.1.0.9"
		insopts --owner=root --group=games --mode=664
		insinto /etc/epsxe
		doins "${S}/alsa/spuPeopsALSA.cfg"
		dosym /etc/epsxe/spuPeopsALSA.cfg "${MERGEDIR}/cfg/spuPeopsALSA.cfg"
		if use config-ui;  then
			insopts --owner=root --group=games --mode=750
			insinto "${MERGEDIR}/cfg"
			doins "${S}/alsa/src/linuxcfg/src/cfgPeopsALSA"
		fi
	fi

	if use pulseaudio; then
		rm -f "${INSTALLDIR}/plugins/remove.me"
		rm -f "${INSTALLDIR}/cfg/erase.me"
		insopts --owner=root --group=root --mode=644
		insinto "${MERGEDIR}/plugins"
		doins "${S}/pulse/src/libspuPeopsPA.so.1.0.9"
		insopts --owner=root --group=games --mode=664
		insinto /etc/epsxe
		doins "${S}/pulse/spuPeopsPA.cfg"
		dosym /etc/epsxe/spuPeopsPA.cfg "${MERGEDIR}/cfg/spuPeopsPA.cfg"
		if use config-ui; then
			insopts --owner=root --group=games --mode=750
			insinto "${MERGEDIR}/cfg"
			doins "${S}/pulse/src/linuxcfg/src/cfgPeopsPA"
		fi
	fi

	if use nullspu; then
		rm -f "${INSTALLDIR}/plugins/remove.me"
		rm -f "${INSTALLDIR}/cfg/erase.me"
		insopts --owner=root --group=root --mode=644
		insinto "${MERGEDIR}/plugins"
		doins "${S}/libspuPeteNull.so.1.0.1"
		if use doc; then
			insopts --owner=root --group=root --mode=644
			insinto "${MERGEDIR}/docs"
			doins "${S}/spuPeteNull_readme.txt"
		fi
	fi

	if use menu; then
		insopts --owner=root --group=root --mode=644
		insinto "${MERGEDIR}"
		doins "${S}/epsxe.ico"
		echo "[Desktop Entry]" > epsxe.desktop || die "Install failed!"
		echo "Name=ePSXe" >> epsxe.desktop || die "Install failed!"
		echo "Comment=Playstation Emulator" >> epsxe.desktop || die "Install failed!"
		echo "Exec=${MERGEDIR}/epsxe" >> epsxe.desktop || die "Install failed!"
		echo "Icon=${MERGEDIR}/epsxe.ico" >> epsxe.desktop || die "Install failed!"
		echo "Terminal=false" >> epsxe.desktop || die "Install failed!"
		echo "Type=Application" >> epsxe.desktop || die "Install failed!"
		echo "Categories=Game;Emulator;" >> epsxe.desktop || die "Install failed!"
		domenu epsxe.desktop || die "Install failed!"
	fi

	echo "#!/bin/sh" > epsxe-run || die "Install failed!"
	echo "cd ${MERGEDIR}" >> epsxe-run || die "Install failed!"
	echo "./epsxe \$@" >> epsxe-run || die "Install failed!"
	insopts --owner=root --group=root --mode=755
	insinto "${MERGEDIR}"
	doins epsxe-run
	dosym "${MERGEDIR}/epsxe-run" /usr/bin/epsxe

}
