#!/bin/bash

echo $PATH
which rcs-latexdiff

# create iuf-rulebook.pdf
make pdf

#TODO: translations


#create diffs (TODO)
touch diff-branches
make diff DIFFBRANCH=2013
# - for oldcommit in $(cat diff-branches); do make diff NEWCOMMIT=$TRAVIS_BRANCH OLDCOMMIT=$oldcommit; done
