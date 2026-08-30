#!/usr/bin/env bash

set -euo pipefail
. "$(dirname "$0")/../lib.sh"

old_file=$1
new_version=$2

[[ "$old_file" == *.ebuild ]] || exit 0

rename_ebuild "$old_file" "$new_version" >/dev/null
