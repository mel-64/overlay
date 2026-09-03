repo := "melody"
set shell := ["bash", "-uc"]

pkg_from_dir := trim_start_match(trim_start_match(invocation_directory(), justfile_directory()), '/')

default:
    @just --list

# Add new ebuild
new pkg url version="":
    .scripts/new-ebuild.sh "{{pkg}}" "{{url}}" "{{version}}"

# Run pkgcheck QA checks over the repository
[no-cd]
scan:
    pkgcheck scan .

# Commit changes with pkgdev QA checks
commit:
    pkgdev commit

# Push commits
push:
    pkgdev push

# Sync this overlay from remote into /var/db/repos
sync:
    sudo emaint sync --repo {{repo}}

# Create the initial metadata.xml file
[no-cd]
[script]
metadata-init ebuild='':
    source "{{justfile_directory()}}/.scripts/lib.sh"
    ebuild="{{ebuild}}"
    cd {{justfile_directory()}}
    [[ -z "{{ebuild}}" ]] && ebuild="$(resolve_ebuild_path {{pkg_from_dir}})"
    cd -
    metagen -e $(git config author.email) --type person -f
    gentle "$(basename $ebuild)"

# Add useflag to metadata.xml
[no-cd]
use-add flag description:
    xq -ix '.pkgmetadata.use.flag |= (if type == "object" then [.] else . end) | .pkgmetadata.use.flag += [{"@name": "{{flag}}", "#text": "{{description}}"}]' metadata.xml

# Call `use-add` with "add {{flag}} support"
[no-cd]
use-add-support flag:
    just use-add "{{flag}}" "add {{flag}} support"

# Open a packages homepage in default browser (often source repo)
[script]
open-homepage pkg=pkg_from_dir:
    source "./.scripts/lib.sh"
    xdg-open "$(get_ebuild_var '{{pkg}}' HOMEPAGE)"
