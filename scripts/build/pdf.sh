#!/bin/bash -e

SRC=$1
FILE_SUFFIX=$2
# turn src/ -> tmp/out
# turn tmp/src_de/ -> tmp/out_de
OUT=$(echo tmp/$SRC | sed s/tmp\\/tmp\\//tmp\\// | sed s/src/out/)

mkdir -p $OUT
mkdir -p pdf

LATEXARGS=" -output-directory=$OUT -interaction=batchmode -file-line-error -halt-on-error"

TEXINPUTS=$SRC: pdflatex $LATEXARGS -draftmode $SRC/iuf-rulebook.tex
TEXINPUTS=$SRC: pdflatex $LATEXARGS            $SRC/iuf-rulebook.tex
mv $OUT/iuf-rulebook.pdf pdf/iuf-rulebook-$FILE_SUFFIX.pdf;
