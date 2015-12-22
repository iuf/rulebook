#!/bin/bash

echo $PATH
which rcs-latexdiff

# create iuf-rulebook.pdf
make rulebook

#TODO: translations


#create diffs (TODO)
touch diff-branches
make diff
# - for oldcommit in $(cat diff-branches); do make diff NEWCOMMIT=$TRAVIS_BRANCH OLDCOMMIT=$oldcommit; done
