#!/usr/bin/env bash
resolve_ebuild_path() {
    local target=$1
    if [[ -d $target ]]; then
        ls "$target"/*.ebuild | sort -V | tail -n 1
    elif [[ -f $target ]]; then
        echo "$target"
    else
        echo "no ebuild at $target" >&2
        return 1
    fi
}

fetch_source() {
    local url=$1 dir=$2 entries
    mkdir -p "$dir"
    curl -fsSL "$url" | tar -xzf - -C "$dir"
    # Tarball contents are often nested, return subdir if so
    entries=("$dir"/*)
    if ((${#entries[@]} == 1)) && [[ -d ${entries[0]} ]]; then
        echo "${entries[0]}"
    else
        echo "$dir"
    fi
}

get_package_name() {
    local target=$1
    [[ -d $target ]] || target=$(dirname "$target")
    basename "$target"
}

rename_ebuild() {
    local old_file=$1 new_version=$2 new_file
    new_file="$(dirname "$old_file")/$(get_package_name "$old_file")-$new_version.ebuild"
    mv "$old_file" "$new_file"
    echo "$new_file"
}

resolve_forge() {
    local host=$1 owner=$2 repo_name=$3
    if [[ $host == github.com ]]; then
        echo "https://api.github.com/repos/$owner/$repo_name"
    else
        echo "https://$host/api/v1/repos/$owner/$repo_name"
    fi
}

get_renovate_meta() {
    local host=$1 owner=$2 repo_name=$3 version=$4
    if [[ $host == github.com ]]; then
        echo "# renovate: datasource=github-tags depName=$owner/$repo_name"
    else
        echo "# renovate: datasource=forgejo-tags depName=$owner/$repo_name packageName=$owner/$repo_name registryUrl=https://$host"
    fi
    echo "# Current version: $version"
}

fetch_description() {
    local url=$1 pkg=$2 desc
    desc=$(curl -fsSL "$url" | jq -r '.description')
    [[ ${#desc} -gt 80 && $desc == *.* ]] && desc=${desc%%.*}
    desc=${desc%[.,:; ]}
    [[ ${#desc} -gt 80 ]] && desc="${desc:0:77}..."
    [[ -n $desc ]] || desc="$pkg"
    echo "$desc"
}

is_cargo_ebuild() {
    local inherit_line
    inherit_line=$(grep -E '^[[:space:]]*inherit[[:space:]]' "$1" || true)
    [[ "$inherit_line" =~ (^|[[:space:]])cargo([[:space:]]|$) ]]
}
