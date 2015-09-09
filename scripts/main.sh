#!/bin/bash

# create iuf-rulebook.pdf
make BRANCHNAME=$TRAVIS_BRANCH

#TODO: translations


#create diffs (TODO)
touch diff-branches
make diff NEWCOMMIT=$TRAVIS_BRANCH OLDCOMMIT=2013
# - for oldcommit in $(cat diff-branches); do make diff NEWCOMMIT=$TRAVIS_BRANCH OLDCOMMIT=$oldcommit; done
