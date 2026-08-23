#!/usr/bin/env bash

set -euo pipefail

old_file=$1
new_version=$2

[[ "$old_file" == *.ebuild ]] || exit 0

package_dir=$(dirname "$old_file")
package_name=$(basename "$package_dir")

new_file="${package_dir}/${package_name}-${new_version}.ebuild"

mv "$old_file" "$new_file"
