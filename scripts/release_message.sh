#!/bin/bash

set -e

git log --no-merges --oneline `git describe --tags --abbrev=0`...master > release_changelog.txt

cat release_changelog.txt | awk '{printf "%s\\n", $0}' | sed 's/"/\\\"/g' | sed "s/'//g"