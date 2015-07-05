# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit fdo-mime gnome2-utils dotnet versionator eutils

DESCRIPTION="Integrated Development Environment for .NET"
HOMEPAGE="http://www.monodevelop.com/"
SRC_URI="http://download.mono-project.com/sources/${PN}/${P}.tar.bz2
	https://launchpadlibrarian.net/68057829/NUnit-2.5.10.11092.zip
	https://www.nuget.org/api/v2/package/NUnit/2.6.3 -> NUnit.2.6.3.zip
	https://www.nuget.org/api/v2/package/NUnit.Runners/2.6.3  -> NUnit.Runners.2.6.3.zip
	https://www.nuget.org/api/v2/package/System.Web.Mvc.Extensions.Mvc.4/1.0.9 -> System.Web.Mvc.Extensions.Mvc.4.1.0.9.zip
	https://www.nuget.org/api/v2/package/Microsoft.AspNet.Mvc/5.2.2 -> Microsoft.AspNet.Mvc.5.2.2.zip
	https://www.nuget.org/api/v2/package/Microsoft.AspNet.Razor/3.2.2 -> Microsoft.AspNet.Razor.3.2.2.zip
	https://www.nuget.org/api/v2/package/Microsoft.AspNet.WebPages/3.2.2 -> Microsoft.AspNet.WebPages.3.2.2.zip
	https://www.nuget.org/api/v2/package/Microsoft.Web.Infrastructure/1.0.0.0 -> Microsoft.Web.Infrastructure.1.0.0.0.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="+subversion +git doc +gnome qtcurve"

RDEPEND=">=dev-lang/mono-3.2.8
	>=dev-dotnet/nuget-2.8.3
	gnome? ( >=dev-dotnet/gnome-sharp-2.24.2-r1 )
	>=dev-dotnet/gtk-sharp-2.12.21:2
	>=dev-dotnet/mono-addins-1.0[gtk]
	doc? ( dev-util/mono-docbrowser )
	>=dev-dotnet/xsp-2
	dev-util/ctags
	sys-apps/dbus[X]
	subversion? ( dev-vcs/subversion )
	!<dev-util/monodevelop-boo-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-java-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-database-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-debugger-gdb-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-debugger-mdb-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-vala-$(get_version_component_range 1-2)"
DEPEND="${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext
	x11-misc/shared-mime-info
	x11-terms/xterm
	app-arch/unzip"
MAKEOPTS="${MAKEOPTS} -j1" #nowarn
S="${WORKDIR}/monodevelop-5.9"

src_unpack() {
	unpack "${P}".tar.bz2  NUnit-2.5.10.11092.zip
	mkdir monodevelop-5.9/packages || die
	cd monodevelop-5.9/packages || die

	for pkg in NUnit.2.6.3 \
				NUnit.Runners.2.6.3 \
				System.Web.Mvc.Extensions.Mvc.4.1.0.9 \
				Microsoft.AspNet.Mvc.5.2.2 \
				Microsoft.AspNet.Razor.3.2.2 \
				Microsoft.AspNet.WebPages.3.2.2 \
				Microsoft.Web.Infrastructure.1.0.0.0
	do
		mkdir $pkg || die
		cd $pkg || die
		unpack $pkg.zip
		cd .. || die
	done
}

src_prepare() {
	# Remove the git rev-parse (changelog?)
	sed -i '/<Exec.*rev-parse/ d' "${S}/src/core/MonoDevelop.Core/MonoDevelop.Core.csproj" || die
	# Set specific_version to prevent binding problem
	# when gtk#-3 is installed alongside gtk#-2
	find "${S}" -name '*.csproj' -exec sed -i 's#<SpecificVersion>.*</SpecificVersion>#<SpecificVersion>True</SpecificVersion>#' {} + || die

	#copy missing binaries
	cp -fR "${WORKDIR}"/NUnit-2.5.10.11092/bin/net-2.0/framework/* "${S}"/external/cecil/Test/libs/nunit-2.5.10/ || die

	#fix ASP.Net
	epatch "${FILESDIR}/5.7-downgrade_to_mvc3.patch"
	# fix for https://github.com/gentoo/dotnet/issues/42
	epatch "${FILESDIR}/aspnet-template-references-fix.patch"
	use gnome || epatch "${FILESDIR}/kill-gnome.patch"
	use qtcurve && epatch "${FILESDIR}/kill-qtcurve-warning.patch"
}

src_configure() {
	# env vars are added as the fix for https://github.com/gentoo/dotnet/issues/29
	MCS=/usr/bin/dmcs CSC=/usr/bin/dmcs GMCS=/usr/bin/dmcs econf \
		--disable-update-mimedb \
		--disable-update-desktopdb \
		--enable-monoextensions \
		--enable-gnomeplatform \
		$(use_enable subversion) \
		$(use_enable git)
	# https://github.com/mrward/xdt/issues/4
	# Main.sln file is created on the fly during econf
	epatch -p2 "${FILESDIR}/mrward-xdt-issue-4.patch"
	# fix of https://github.com/gentoo/dotnet/issues/38
	sed -i -E -e 's#(EXE_PATH=")(.*)(/lib/monodevelop/bin/MonoDevelop.exe")#\1'${EPREFIX}'/usr\3#g' "${S}/monodevelop" || die
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
}
