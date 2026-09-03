repo := "melody"

default:
    @just --list

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
metadata-init ebuild:
    metagen -e $(git config author.email) --type person -f
    gentle "{{ebuild}}"

# Add useflag to metadata.xml
[no-cd]
use-add flag description:
    xq -ix '.pkgmetadata.use.flag |= (if type == "object" then [.] else . end) | .pkgmetadata.use.flag += [{"@name": "{{flag}}", "#text": "{{description}}"}]' metadata.xml
