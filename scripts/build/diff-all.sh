#!/usr/bin/env bash
set -e # POSIX version of bash -e

for DIFFBRANCH in $(cat diff-branches); do
    scripts/build/diff.sh $DIFFBRANCH
done
