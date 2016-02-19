#!/bin/bash -e
BRANCH=$1
CHAPTERDIR=src
CHAPTERS=$(ls $CHAPTERDIR | grep -P "^\\d\\d_.*\\.tex$")

PO4ACHARSETS="--master-charset Utf-8 --localized-charset Utf-8"
LATEXARGS="-output-directory=out -interaction=batchmode -file-line-error -halt-on-error"

export TEXINPUTS=src

# rm -rf .tx
# tx init --host=https://www.transifex.com

# for CHAPTER in $CHAPTERS; do
#     SLUG=$(echo $CHAPTER | sed -e "s/[0-9][0-9]_\(.*\)\.tex/\1/")
#     echo $SLUG
#     echo $CHAPTERDIR/$CHAPTER
#     po4a-gettextize --format latex --master $CHAPTERDIR/$CHAPTER --po pot/${SLUG}_template.pot $PO4ACHARSETS

#     tx set --auto-local --resource=rulebook-$BRANCH.$SLUG "po/<lang>/${SLUG}.po" --type PO --source-lang en --source-file pot/${SLUG}_template.pot --execute
# done

# tx push --source
# tx pull --all

po4a-gettextize --format latex --master ./src/iuf-rulebook.tex --option 'exclude_include=preamble' --po pot/iuf-rulebook.pot $PO4ACHARSETS


# merge po files for whole document
for LANG in $(ls po); do
    echo $LANG
    msgcat po/$LANG/*.po -o out/$LANG.po.concat
    msgmerge out/$LANG.po.concat pot/iuf-rulebook.pot > out/$LANG.po
    # generate translated tex files
    # TEXINPUTS=src po4a --variable lang=$LANG --variable branch=$BRANCH --variable repo=. $PO4ACHARSETS config/po4a.cfg
done


# for LANG in po/*; do
#     pdflatex $LATEXARGS -draftmode out/iuf-rulebook-$BRANCH-$LANG.tex
#     pdflatex $LATEXARGS            out/iuf-rulebook-$BRANCH-$LANG.tex
#     mv out/iuf-rulebook-$BRANCH-$LANG.pdf pdf
# done

# for CHAPTER in $CHAPTERS; do
#     SLUG=$(echo $CHAPTER | sed -e "s/[0-9][0-9]_\(.*\)\.tex/\1/")
#     echo $SLUG
#     echo $CHAPTERDIR/$CHAPTER


# done
