#!/usr/bin/env bash
# pkgcore can't resolve repos.conf-defined masters, so regenerate the Manifest
# in a self-contained temp repo instead.

set -euo pipefail

[[ "$1" == *.ebuild ]] || exit 0

package_dir=$(dirname "$1")
category=$(basename "$(dirname "$package_dir")")
pkg=$(basename "$package_dir")
mirror="https://mirrors.shork.ch/gentoo/"

[[ -f "$package_dir/Manifest" ]] || exit 0

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
repo_name=$(cat "$repo_root/profiles/repo_name" 2>/dev/null || basename "$repo_root")

work=$(mktemp -d)
distdir=$(mktemp -d)
trap 'rm -rf "$work" "$distdir"' EXIT

mkdir -p "$work/metadata" "$work/profiles/default" \
    "$work/config" "$work/$category/$pkg" "$work/eclass"
curl -fsSL "$mirror/eclass/Manifest.gz" -o "$work/eclass-manifest.gz"
zcat "$work/eclass-manifest.gz" | awk '$2 ~ /\.eclass$/ {print $2}' \
    | xargs -P8 -I{} curl -fsSL "$mirror/eclass/{}" -o "$work/eclass/{}"

printf 'masters =\nrepo-name = %s\n' "$repo_name" > "$work/metadata/layout.conf"
printf '%s\n' "$repo_name" > "$work/profiles/repo_name"
printf '%s\n' "$category" > "$work/profiles/categories"
printf 'ARCH="amd64"\nCHOST="x86_64-pc-linux-gnu"\n' > "$work/profiles/default/make.defaults"

cp "$package_dir"/*.ebuild "$package_dir/Manifest" "$work/$category/$pkg/"

cat > "$work/config/repos.conf" <<EOF
[DEFAULT]
main-repo = $repo_name

[$repo_name]
location = $work
EOF

ln -s "$work/profiles/default" "$work/config/make.profile"
echo -n "" > "$work/config/make.conf"

(cd "$work" && uv tool run pkgdev manifest \
    --config "$work/config" -d "$distdir" "$category/$pkg")

cp "$work/$category/$pkg/Manifest" "$package_dir/Manifest"
