# Gentoo overlay

My personal overlay possibly providing a few ebuilds

[![workflow-badge](https://git.shork.ch/melody/overlay/badges/workflows/check_header.yaml/badge.svg)](https://git.shork.ch/melody/overlay/actions)
[![workflow-badge](https://git.shork.ch/melody/overlay/badges/workflows/qa.yaml/badge.svg)](https://git.shork.ch/melody/overlay/actions)

Update checker (/ renovate dependency tracker) viewable [here](https://git.shork.ch/melody/overlay/issues/1)

## Renovate

Renovate parses metadata from two comment lines in the respective ebuild files.

Example:
```
# renovate: datasource=forgejo-tags depName=forgejo-contrib/forgejo-cli packageName=forgejo-contrib/forgejo-cli registryUrl=https://codeberg.org
# Current version: 0.6.0
```
