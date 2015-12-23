#!/bin/bash

# travis does a "shallow clone" on exactly one branch, so we need to unshallow and fetch all other branches
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch

# track all remote branches, to macke them accessible to latexdiff
for remote in `git branch -r `; do git branch --track $remote; done

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
