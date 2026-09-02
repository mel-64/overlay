#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/lib.sh"

pkg_path=$1
repo_url=$2
version=$3
src=$4
tag_prefix=${5-v}

pkg=${pkg_path##*/}

mkdir -p "$pkg_path"
file="$pkg_path/$pkg-$version.ebuild"
pycargoebuild -o "$file" -e "$src"

sed -i "s|^SRC_URI=\"|&\n\t$repo_url/archive/${tag_prefix}\${PV}.tar.gz -> \${P}.tar.gz|" "$file"

topdir=${src##*/}
[[ $topdir == "$pkg-$version" ]] || sed -i "/^LICENSE=/i S=\"\${WORKDIR}/$topdir\"" "$file"

declare -A edition_msrv=(
    [2024]="1.85.0"
    [2021]="1.56.0"
)
edition=$(tomlq -r .package.edition "$src/Cargo.toml" 2>/dev/null || true)
msrv=$(tomlq -r '.package."rust-version"' "$src/Cargo.toml" 2>/dev/null || true)
[[ $msrv =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] || msrv=""
[[ $msrv =~ ^[0-9]+\.[0-9]+$ ]] && msrv+=".0"

# Minimum profile rust version
profile_min=$(grep -oP '_CARGO_ECLASS_RUST_MIN_VER="\K[^"]+' /var/db/repos/gentoo/eclass/cargo.eclass)

edition_min="${edition_msrv[$edition]:-}"

if [[ -n $msrv ]]; then
    min_rust_ver=$msrv
else
    min_rust_ver=$edition_min
fi

# We should not write RUST_MIN_VER for versions smaller or equal to what the eclass defines as the minimum.
[[ $(printf '%s\n' "$profile_min" "$min_rust_ver" | sort -V | head -n1) == "$min_rust_ver" ]] && exit 0

sed -i "/^inherit cargo$/i RUST_MIN_VER=\"$min_rust_ver\"" "$file"
