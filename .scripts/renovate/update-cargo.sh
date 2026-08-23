#!/usr/bin/env bash

set -euo pipefail

old_file=$1
new_version=$2

package_dir=$(dirname "$old_file")
package_name=$(basename "$package_dir")
new_file="${package_dir}/${package_name}-${new_version}.ebuild"
mirror="https://mirrors.shork.ch/gentoo/"

inherit_line=$(grep -E '^[[:space:]]*inherit[[:space:]]' "$new_file" || true)
if [[ ! "$inherit_line" =~ (^|[[:space:]])cargo([[:space:]]|$) ]]; then
    echo "not a cargo ebuild. skipping.."
    exit 0
fi

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

archive="$workdir/source-archive"
curl -fsSL "$url" -o "$archive"

mkdir -p "$workdir/src"
tar -xf "$archive" -C "$workdir/src"

# There's very often an additional dir between root and actual source
src_dir=$(find "$workdir/src" -mindepth 1 -maxdepth 1 -type d -print -quit)
src_dir=${src_dir:-"$workdir/src"}

curl -fsSL "$mirror/metadata/license-mapping.conf" \
    -o "$workdir/license-mapping.conf"

uv tool run pycargoebuild -i "$new_file" \
    -d "$workdir/dist" \
    -l "$workdir/license-mapping.conf" \
    --no-manifest \
    "$src_dir"
