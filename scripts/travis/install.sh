#!/bin/bash -e

install() {
    # travis does a "shallow clone" on exactly one branch, so we need to unshallow and fetch all other branches, to be able to diff against them.
    git_fetch_all_branches


    # gitinfo is a latex package which allows to put git metadata (like current hash) into the latex document.
    install_gitinfo

    # scrlayer-scrpage is a latex package for header styles
    install_scrlayer

    # latexdiff can generate a tex file highlighting the changes between two similar tex files. It can extract the two versions from git references.
    install_latexdiff

    # handles online translations on transifex.com
    install_transifex_client
}

install_latexdiff() {
    current=`pwd`
    mkdir -p $HOME/local/latexdiff/bin
    mkdir -p $HOME/local/latexdiff/man/man1
    git clone https://github.com/ftilmann/latexdiff.git
    cd latexdiff/latexdiff-1.1.0
    make install INSTALLPATH=$HOME/local/latexdiff
    cd $current
}

install_gitinfo() {
    cp -a dependencies/gitinfo2/* src
    ./scripts/install-git-hooks.sh
}

install_scrlayer() {
    cp -a dependencies/scrlayer/* src
}

install_transifex_client() {
    pip install transifex-client
}

git_fetch_all_branches() {
    # cache current branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    git fetch

    # track all remote branches
    for remote in `git branch -r | grep -v /HEAD`; do
        git checkout --track $remote || true
    done

    # checkout originally selected branch
    git checkout $current_branch
}

install
