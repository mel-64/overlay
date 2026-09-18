# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Adapted from ell07 overlay

# renovate: datasource=github-tags depName=jjsullivan5196/wvkbd
# Current version: 0.20

EAPI=8

DESCRIPTION="On-screen keyboard for wlroots that sucks less"
HOMEPAGE="https://github.com/jjsullivan5196/wvkbd"

SRC_URI="https://github.com/jjsullivan5196/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${PV}"
# po/* are licensed under BSD 3-clause
LICENSE="MIT GPL-3+"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE="+mobintl deskintl"
REQUIRED_USE="^^ ( mobintl deskintl )"

COMMON_DEPEND="dev-libs/wayland
	x11-libs/cairo
	x11-libs/libxkbcommon
	x11-libs/pango
"

DEPEND="${COMMON_DEPEND}
	app-text/scdoc"
RDEPEND="${COMMON_DEPEND}"

RESTRICT="mirror test"

src_prepare() {
	sed -i 's:^PREFIX = .*:PREFIX = /usr:g' "${S}/config.mk"

	use mobintl && sed -i 's:^LAYOUT = .*:LAYOUT = mobintl:g' "${S}/config.mk"
	use deskintl && sed -i 's:^LAYOUT = .*:LAYOUT = deskintl:g' "${S}/config.mk"

	default
}

src_install() {
	emake DESTDIR="${D}" install
	einstalldocs
	use mobintl && dosym wvkbd-mobintl "/usr/bin/wvkbd"
	use deskintl && dosym wvkbd-deskintl "/usr/bin/wvkbd"
}
