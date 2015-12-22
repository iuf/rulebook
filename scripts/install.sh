#!/bin/bash

# get branches
git checkout $TRAVIS_BRANCH # attach to HEAD
git branch -a

#for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v travis`; do
#   git branch --track ${branch##*/} $branch;
# done

for branch in $(cat diff-branches); do
  git branch --track $branch;
done

git fetch --all
git pull --all
git branch
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
# cd latexdiff/latexdiff-1.1.0
cd latexdiff/latexdiff-1.0.4
make install INSTALLPATH=$HOME/local/latexdiff
cd

# rcs-latexdiff
mkdir -p $HOME/local/rcs-latexdiff
git clone https://github.com/driquet/rcs-latexdiff.git
cd rcs-latexdiff
virtualenv --prompt==rcs-latexdiff venv
source venv/bin/activate
python setup.py install
cd

# list (debug?)
ls -R ~

cd $current
