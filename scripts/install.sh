#!/bin/bash

# travis does a "shallow clone" on exactly one branch, so we need to unshallow and fetch all other branches
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch

current_branch=$(git rev-parse --abbrev-ref HEAD)

# track all remote branches, to make them accessible to latexdiff-vc
for remote in `git branch -r | grep -v /HEAD`; do
    git checkout --track $remote
done

git checkout $current_branch
git branch



current=`pwd`

# binaries
# not here. $PATH must be set in .travis.yml, see http://docs.travis-ci.com/user/installing-dependencies/

# git metadata in pdf
echo "installing gitinfo"
pwd
cp -a dependencies/gitinfo2/* src
ls -l src
./hooks/post-checkout
ls -l .git

# latexdiff
mkdir -p $HOME/local/latexdiff/bin
mkdir -p $HOME/local/latexdiff/man/man1
git clone https://github.com/ftilmann/latexdiff.git
cd latexdiff/latexdiff-1.1.0
make install INSTALLPATH=$HOME/local/latexdiff
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
