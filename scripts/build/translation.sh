#!/bin/bash -e
BRANCH=$(git rev-parse --abbrev-ref HEAD)
CHAPTERDIR=src/chapters
CHAPTERS=$(ls $CHAPTERDIR | grep -P "^\\d\\d_.*\\.tex$")

PO4ACHARSETS="--master-charset Utf-8 --localized-charset Utf-8"
LATEXARGS="-file-line-error -halt-on-error"

rm -rf .tx
tx init --host=https://www.transifex.com

mkdir -p tmp
mkdir -p pdf

# extract translation templates for each chapter and write them to transifex config file (.tx/config)
# (for current branch)
for CHAPTER in $CHAPTERS; do
    SLUG=$(echo $CHAPTER | sed -e "s/[0-9][0-9]_\(.*\)\.tex/\1/")
    echo $SLUG
    echo $CHAPTERDIR/$CHAPTER
    TEXINPUTS=src po4a-gettextize --format latex --master $CHAPTERDIR/$CHAPTER --po tmp/po/${SLUG}/template.pot $PO4ACHARSETS

    tx set --auto-local --resource=rulebook-$BRANCH.$SLUG "tmp/po/${SLUG}/<lang>.po" --type PO --source-lang en --source-file tmp/po/${SLUG}/template.pot --execute
done

# upload all tempates to transifex
tx push --source
# download all translated strings from transifex
tx pull --all

# extracts the list of languages by looking at one chapter's po-files
LANGUAGES=$(ls tmp/po/$(ls tmp/po | head -1)/*.po | xargs -n1 basename | sed "s/\\.po$//")

for LANG in $LANGUAGES; do
    cp --archive --no-target-directory src tmp/src_$LANG
done

for CHAPTER in $CHAPTERS; do
    SLUG=$(echo $CHAPTER | sed -e "s/[0-9][0-9]_\(.*\)\.tex/\1/")

    TEXINPUTS=./src po4a --variable chapter_file=$CHAPTER --variable chapter_slug=$SLUG $PO4ACHARSETS config/po4a.cfg
done

for LANG in $LANGUAGES; do
    mkdir -p tmp/out_$LANG

    TEXINPUTS=tmp/src_$LANG: latexmk -pdf $LATEXARGS -output-directory=./tmp/out_$LANG tmp/src_$LANG/iuf-rulebook.tex
    # remove -quiet if the build is failing to figure out where
    mv tmp/out_$LANG/iuf-rulebook.pdf pdf/iuf-rulebook-$BRANCH-$LANG.pdf
done
