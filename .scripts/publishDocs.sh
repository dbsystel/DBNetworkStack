#!/usr/bin/env bash

set -e # exit with nonzero exit code if anything fails

# clear and re-create the out directory
rm -rf docs || exit 0;
mkdir docs;

# generate docs
jazzy \
--clean \
--author "Lukas Schmidt, Christian Himmelsbach" \
--github_url https://github.com/dbsystel/DBNetworkStack \
--module DBNetworkStack \
--output docs \
--no-download-badge

# go to the out directory and create a *new* Git repo
cd docs
git init

# The first and only commit to this new Git repo contains all the
# files present with the commit message "Deploy to GitHub Pages".
git add .
git commit -m "Deploy documentation to GitHub Pages"

# Force push from the current repo's master branch to the remote
# repo's gh-pages branch. (All previous history on the gh-pages branch
# will be lost, since we are overwriting it.) We redirect any output to
# /dev/null to hide any sensitive credential data that might otherwise be exposed.
git push --force --quiet "https://github.com/dbsystel/DBNetworkStack" master:gh-pages > /dev/null 2>&1
