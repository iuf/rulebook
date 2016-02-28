#!/bin/bash -e

for DIFFBRANCH in $(cat diff-branches); do
    scripts/build/diff.sh $DIFFBRANCH
done
