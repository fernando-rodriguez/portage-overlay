# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Apparmor Policies"
HOMEPAGE="http://github.com/fernando-rodriguez/apparmor-policy/"
SRC_URI="https://github.com/fernando-rodriguez/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="primaryuri"

LICENSE="WTFPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	sys-apps/apparmor
	sys-apps/apparmor-utils"

src_install()
{
	rm -f "${S}"/README.md || die
	rm -f "${S}"/.gitignore || die
	chmod 0750 "${S}"/usr/bin/aa-uexec || die
	find "${S}" -mindepth 1 -maxdepth 1 \
		-exec mv '{}' "${ED}" \; || die
}

pkg_postinst()
{
	einfo "The systemd init script was renamed. If you have"
	einfo "it enabled please run:"
	einfo "systemctl disable apparmor-policy.service"
	einfo "systemctl enable apparmor.service"
}