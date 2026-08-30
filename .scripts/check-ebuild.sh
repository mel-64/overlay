#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/lib.sh"

pkg=$1
ebuild_file=$(resolve_ebuild_path "$pkg")

if [[ $(grep '^ID=' /etc/os-release) != "ID='gentoo'" ]]; then
    echo "skipping compiling in non-gentoo env" 1>&2
else
    ebuild "$ebuild_file" clean compile
fi

pkgcheck scan "$ebuild_file"
