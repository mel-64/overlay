# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# renovate: ignore

EAPI=8

inherit cargo git-r3

DESCRIPTION="CLI to manage emails"
HOMEPAGE="https://github.com/pimalaya/himalaya"

LICENSE="|| ( Apache-2.0 MIT )"
# Dependent crate licenses
LICENSE+="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD
	CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 ZLIB
"
EGIT_REPO_URI="https://github.com/pimalaya/himalaya-tui.git"
SLOT="0"
KEYWORDS=""
IUSE="+imap +smtp +jmap +maildir native-tls rustls-aws vendored +rustls-ring "

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_configure() {
	local myfeatures=(
		$(usev imap)
		$(usev jmap)
		$(usev smtp)
		$(usev maildir)
		$(usev native-tls)
		$(usev rustls-aws)
		$(usev rustls-ring)
		$(usev vendored)
	)
	cargo_src_configure
}
