#!/usr/bin/env bash
set -e # POSIX version of bash -e

make rulebook
echo # insert blank line in travis output
echo -en 'travis_fold:start:build_diffs\\r'
scripts/build/diff-all.sh
echo -en 'travis_fold:end:build_diffs\\r'
echo  #insert blank line in travis output
echo -en 'travis_fold:start:build_translations\\r'
echo starting diff
scripts/build/translation.sh
echo -en 'travis_fold:end:build_translations\\r'
