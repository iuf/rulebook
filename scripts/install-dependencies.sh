#!/usr/bin/env bash
set -e # POSIX version of bash -e

install() {
    # travis does a "shallow clone" on exactly one branch, so we need to unshallow and fetch all other branches, to be able to diff against them.
    git_fetch_all_branches


    # gitinfo is a latex package which allows to put git metadata (like current hash) into the latex document.
    install_gitinfo

    # koma-script is a latex package
    install_koma-script

    # latexdiff can generate a tex file highlighting the changes between two similar tex files. It can extract the two versions from git references.
    install_latexdiff

    # La­texmk com­pletely au­to­mates the pro­cess of gen­er­at­ing a LaTeX doc­u­ment
    install_latexmk

    # handles online translations on transifex.com
    install_transifex_client
}

install_latexdiff() {
    tlmgr install latexdiff
    tlmgr update latexdiff
}

install_latexmk() {
    tlmgr install latexmk
    tlmgr update latexmk
}

install_gitinfo() {
    cp -a dependencies/gitinfo2/* src
    cp -a dependencies/gitinfo2/* .
    ./scripts/install-git-hooks.sh
}

install_koma-script() {
    tlmgr install koma-script
    tlmgr update koma-script
}

install_transifex_client() {
    easy_install pip
    pip install transifex-client
}

git_fetch_all_branches() {
    # cache current branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    git fetch --depth=3

    # track all remote branches
    for remote in `git branch -r | grep -v /HEAD`; do
        git checkout --track $remote || true
    done

    # checkout originally selected branch
    git checkout $current_branch
}

install
