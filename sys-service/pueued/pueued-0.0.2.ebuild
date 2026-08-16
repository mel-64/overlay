EAPI=8

DESCRIPTION="pueue as daemon service script"
HOMEPAGE="https://git.shork.ch/melody/overlay/sys-service/pueued"
S="${WORKDIR}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="app-misc/pueue"

src_install() {
cat > "${T}/${PN}.initd" <<EOF || die
#!/sbin/openrc-run

description="${DESCRIPTION}"

command="/usr/bin/pueued"
command_args="\${PUEUED_OPTS}"
command_user="root:root"

pidfile="/run/\${RC_SVCNAME}.pid"
command_background="yes"

depend() {
    need localmount
}
EOF

    newinitd "${T}/${PN}.initd" "${PN}"

    cat > "${T}/${PN}.confd" <<EOF || die
# Extra command-line arguments
PUEUED_OPTS="-c /etc/pueue.yml"
EOF

    newconfd "${T}/${PN}.confd" "${PN}"
}

pkg_postinst() {
    elog "Enable the service with:"
    elog "  rc-update add ${PN} default"
    elog
    elog "Start it with:"
    elog "  rc-service ${PN} start"
}
