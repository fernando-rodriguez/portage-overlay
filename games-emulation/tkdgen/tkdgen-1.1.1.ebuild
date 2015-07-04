# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="A Tcl/Tk front-end to Genesis Emulator DGen"
HOMEPAGE="http://sourceforge.net/projects/tkdgen/"
SRC_URI="http://downloads.sourceforge.net/project/tkdgen/TkDgen/1.1.1/tkdgen-1.1.1.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Ftkdgen%2Ffiles%2Flatest%2Fdownload%3Fsource%3Drecommended&ts=1435778164&use_mirror=colocrossing -> tkdgen-1.1.1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND="
	sys-apps/sed
"
RDEPEND="${DEPEND}
	>=games-emulation/dgen-sdl-1.33
	>=dev-lang/tcl-8.0.0
"

src_prepare()
{
	mv "${S}/configure" "${S}/configure.orig"
	sed -e 's/eval "test `$WISH vertk`"/true/g' "${S}/configure.orig" | \
	sed -e "s/\s\-\*)/\*);;\n-invalid-opt)/g" > "${S}/configure"
	chmod +x "${S}/configure"

	mv "${S}/Makefile.in" "${S}/Makefile.in.orig"
	sed -e 's/datadir = $(prefix)\/tkdgen/datadir = $(prefix)\/share\/tkdgen/g' "${S}/Makefile.in.orig" | \
	sed -e 's/prefix = \/usr\/local/prefix = $(DEST)\/$(strip @prefix@)/g' | \
	sed -e 's/echo \/usr\/local/echo $(prefix)\/share/g' > "${S}/Makefile.in"
}

src_install()
{
	emake DEST="${D}" install
    echo "[Desktop Entry]" > tkdgen.desktop || die "Install failed!"
    echo "Name=TkDgen" >> tkdgen.desktop || die "Install failed!"
    echo "Comment=A Tcl/Tk front-end to Genesis Emulator DGen" >> tkdgen.desktop || die "Install failed!"
    echo "Exec=/usr/bin/tkdgen" >> tkdgen.desktop || die "Install failed!"
    echo "Icon=/usr/share/tkdgen/imgs/im_tkdgen.gif" >> tkdgen.desktop || die "Install failed!"
    echo "Terminal=false" >> tkdgen.desktop || die "Install failed!"
    echo "Type=Application" >> tkdgen.desktop || die "Install failed!"
    echo "Categories=Game;Emulator;" >> tkdgen.desktop || die "Install failed!"
    domenu tkdgen.desktop || die "Install failed!"
}