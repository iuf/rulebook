#!/usr/bin/env bash
set -e # POSIX version of bash -e

install() {
    # gitinfo is a latex package which allows to put git metadata (like current hash) into the latex document.
    install_gitinfo

    # koma-script is a latex package
    install_koma-script

    # koma-script is a latex package
    install_ulem

    # latexdiff can generate a tex file highlighting the changes between two similar tex files. It can extract the two versions from git references.
    install_latexdiff

    # La­texmk com­pletely au­to­mates the pro­cess of gen­er­at­ing a LaTeX doc­u­ment
    install_latexmk

    # handles online translations on transifex.com
    install_transifex_client

    #latex font
    install_lmodern

}

install_latexdiff() {
    current=`pwd`
    mkdir -p $HOME/local/latexdiff/bin
    mkdir -p $HOME/local/latexdiff/man/man1
    cp -a dependencies/latexdiff/* $HOME/local/latexdiff/bin
    cd $current
}

install_latexmk() {
    current=`pwd`
    mkdir -p $HOME/local/latexmk/bin
    mv dependencies/latexmk/latexmk.pl $HOME/local/latexmk/bin/latexmk
    cd $HOME/local/latexmk/bin/
    chmod +x latexmk
    cd $current
}

install_gitinfo() {
    cp -a dependencies/gitinfo2/* src
    cp -a dependencies/gitinfo2/* .
    ./scripts/install-git-hooks.sh
}

install_koma-script() {
    cp -a dependencies/koma-script/* src
    cp -a dependencies/koma-script/* .
}

install_ulem() {
    cp -a dependencies/ulem.sty src
    cp -a dependencies/ulem.sty .
}

install_lmodern() {
    cp -a dependencies/lmodern.sty src
    cp -a dependencies/lmodern.sty .
}

install_transifex_client() {
    pip install transifex-client
}

install
