#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/lib.sh"

pkg_path=$1
repo_url=$2
version=$3
src=$4

pkg=${pkg_path##*/}

mkdir -p "$pkg_path"
file="$pkg_path/$pkg-$version.ebuild"
pycargoebuild -o "$file" -e "$src"

sed -i "s|^SRC_URI=\"|&\n\t$repo_url/archive/v\${PV}.tar.gz -> \${P}.tar.gz|" "$file"

topdir=${src##*/}
[[ $topdir == "$pkg-$version" ]] || sed -i "/^LICENSE=/i S=\"\${WORKDIR}/$topdir\"" "$file"
