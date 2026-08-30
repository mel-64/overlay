#!/usr/bin/env bash

set -euo pipefail
. "$(dirname "$0")/../lib.sh"

old_file=$1
new_version=$2

[[ "$old_file" == *.ebuild ]] || exit 0

package_dir=$(dirname "$old_file")
package_name=$(get_package_name "$old_file")
new_file="${package_dir}/${package_name}-${new_version}.ebuild"
mirror="https://mirrors.shork.ch/gentoo/"

is_cargo_ebuild "$new_file" || { echo "not a cargo ebuild. skipping.."; exit 0; }

# This extracts *the first* uri in the SRC_URI array.
# Therefore we need to make sure, that the first src url is always the main source
url=$(sed -n '/^SRC_URI=/,/^[^[:space:]]/p' "$new_file" | grep -oE 'https?://[^"[:space:]]+' | head -n1)

# Expain ebuilds vars
url=$(
    sed \
        -e "s|\${PV}|$new_version|g" \
        -e "s|\${P}|$package_name-$new_version|g" \
        -e "s|\${PN}|$package_name|g" \
        <<<"$url"
)

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

src_dir=$(fetch_source "$url" "$workdir/src")

curl -fsSL "$mirror/metadata/license-mapping.conf" \
    -o "$workdir/license-mapping.conf"

uv tool run pycargoebuild -i "$new_file" \
    -d "$workdir/dist" \
    -l "$workdir/license-mapping.conf" \
    --no-manifest \
    "$src_dir"
