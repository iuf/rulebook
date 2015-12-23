#!/bin/bash

# travis does a "shallow clone" on exactly one branch, so we need to unshallow and fetch all other branches
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch

# track all branches to diff against
# this makes git checkout BRANCH work and is needed for latexdiff
for branch in $(cat diff-branches); do
  git branch --track $branch;
done

current=`pwd`

# binaries
# not here. $PATH must be set in .travis.yml, see http://docs.travis-ci.com/user/installing-dependencies/

# git metadata in pdf
cp -a dependencies/gitinfo2/* src
./hooks/post-checkout

# latexdiff
mkdir -p $HOME/local/latexdiff/bin
mkdir -p $HOME/local/latexdiff/man/man1
git clone https://github.com/ftilmann/latexdiff.git
cd latexdiff/latexdiff-1.1.0
make install-fast INSTALLPATH=$HOME/local/latexdiff
cd

# rcs-latexdiff
# mkdir -p $HOME/local/rcs-latexdiff
# git clone https://github.com/driquet/rcs-latexdiff.git
# cd rcs-latexdiff
# virtualenv --prompt==rcs-latexdiff venv
# source venv/bin/activate
# python setup.py install
# cd

# list (debug?)
# ls -R ~

cd $current
