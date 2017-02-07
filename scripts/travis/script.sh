#!/usr/bin/env bash
set -e # POSIX version of bash -e

echo -en 'travis_fold:start:build_rulebook\\r'
scripts/build/rulebook.sh
echo -en 'travis_fold:end:build_rulebook\\r'
echo # insert blank line in travis output
echo -en 'travis_fold:start:build_diffs\\r'
scripts/build/diff-all.sh
echo -en 'travis_fold:end:build_diffs\\r'
echo  #insert blank line in travis output
echo -en 'travis_fold:start:build_translations\\r'
echo starting diff
scripts/build/translation.sh
echo -en 'travis_fold:end:build_translations\\r'
