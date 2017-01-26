#!/usr/bin/env bash
set -e # POSIX version of bash -e

SRC=$1
FILE_SUFFIX=$2
# turn src/ -> tmp/out
# turn tmp/src_de/ -> tmp/out_de
OUT=$(echo tmp/$SRC | sed s/tmp\\/tmp\\//tmp\\// | sed s/src/out/)

mkdir -p $OUT
mkdir -p pdf

LATEXARGS=" -output-directory=$OUT -file-line-error -halt-on-error"

TEXINPUTS=$SRC: openout_any=a latexmk -pdf -quiet $LATEXARGS $SRC/iuf-rulebook.tex
# remove -quiet if the build is failing to figure out where

mv $OUT/iuf-rulebook.pdf pdf/iuf-rulebook-$FILE_SUFFIX.pdf;
