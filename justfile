repo := "melody"

default:
    @just --list

new pkg url version="":
    .scripts/new-ebuild.sh "{{pkg}}" "{{url}}" "{{version}}"

# Run pkgdev QA checks over the repository
scan:
    pkgdev scan .

# Commit changes with pkgdev QA checks
commit:
    pkgdev commit

# Push commits
push:
    pkgdev push

# Sync this overlay from remote into /var/db/repos
sync:
    sudo emaint sync --repo {{repo}}

