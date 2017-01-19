#!/bin/bash -e

SRC=$1
FILE_NAME=$2
# turn src/ -> tmp/out
# turn tmp/src_de/ -> tmp/out_de
OUT=$(echo tmp/$SRC | sed s/tmp\\/tmp\\//tmp\\// | sed s/src/out/)

mkdir -p $OUT
mkdir -p pdf

# LATEXARGS=" -output-directory=$OUT -file-line-error -halt-on-error"
LATEXARGS=" -output-directory=$OUT -interaction=batchmode -file-line-error -halt-on-error"

TEXINPUTS=$SRC: openout_any=a pdflatex $LATEXARGS -draftmode $SRC/$FILE_NAME.tex
TEXINPUTS=$SRC: openout_any=a pdflatex $LATEXARGS            $SRC/$FILE_NAME.tex
mv $OUT/$FILE_NAME.pdf pdf/$FILE_NAME.pdf;
