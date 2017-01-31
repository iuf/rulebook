#!/usr/bin/env bash
set -e # POSIX version of bash -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)
CHAPTERDIR=src/chapters # set this first so we can create the chapters list
CHAPTERS=$(ls $CHAPTERDIR | grep ".*\.tex$")

PO4ACHARSETS="--master-charset Utf-8 --localized-charset Utf-8"
LATEXARGS="-file-line-error -halt-on-error"

rm -rf .tx
tx init --host=https://www.transifex.com

mkdir -p tmp
mkdir -p pdf
mkdir -p tmp/src_translation

rsync -az src/ tmp/src_translation/

CHAPTERDIR=tmp/src_translation/chapters # now update the chapter dir to the new location

# replace iftoggles that have a true and a false option
sed -i.bak 's~^[[:blank:]]*\\iftoggle{[[:alnum:]_][[:alnum:]_]*}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}~\\input{\1}\\input{\2}~' $CHAPTERDIR/*.tex
#replace iftoggles that only have a true option
sed -i.bak 's~^[[:blank:]]*\\iftoggle{[[:alnum:]_][[:alnum:]_]*}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}{}~\\input{\1}~' $CHAPTERDIR/*.tex

# the -i.bak is required so SED works on both OSX and Linux (BSD and GNU sed)
rm -f $CHAPTERDIR/*.bak # because of this, we have to delete the .bak files after


# extract translation templates for each chapter and write them to transifex config file (.tx/config)
# (for current branch)
for CHAPTER in $CHAPTERS; do
    SLUG=$(echo $CHAPTER | sed -e "s/[0-9][0-9]_\(.*\)\.tex/\1/")
    echo $SLUG
    echo $CHAPTERDIR/$CHAPTER
    echo -e '0r config/po4a-escape.tex\nw' | ed -s $CHAPTERDIR/$CHAPTER # add po4a escape commands to the beginning of each chapter
    TEXINPUTS=$CHAPTERDIR po4a-gettextize --format latex --master $CHAPTERDIR/$CHAPTER --po tmp/po/${SLUG}/template.pot $PO4ACHARSETS

    tx set --auto-local --resource=rulebook-$BRANCH.$SLUG "tmp/po/${SLUG}/<lang>.po" --type PO --source-lang en --source-file tmp/po/${SLUG}/template.pot --execute
done

# upload all tempates to transifex
tx push --source
# download all translated strings from transifex
tx pull --all

# extracts the list of languages by looking at one chapter's po-files
LANGUAGES=$(ls tmp/po/$(ls tmp/po | head -1)/*.po | xargs -n1 basename | sed "s/\\.po$//")

echo "Languages:"
echo $LANGUAGES

for LANG in $LANGUAGES; do
    mkdir -p tmp/src_$LANG
    rsync -a tmp/src_translation/ tmp/src_$LANG
done

ls tmp
ls tmp/src_translation/chapters

for CHAPTER in $CHAPTERS; do
    SLUG=$(echo $CHAPTER | sed -e "s/[0-9][0-9]_\(.*\)\.tex/\1/")

    #TODO what's this texinput for?
    TEXINPUTS=./tmp/src_translation/chapters po4a --variable chapter_file=$CHAPTER --variable chapter_slug=$SLUG $PO4ACHARSETS config/po4a.cfg
done

#TODO: language specific titlepage

for LANG in $LANGUAGES; do
    mkdir -p tmp/out_$LANG

    TEXINPUTS=tmp/src_$LANG: latexmk -pdf -quiet $LATEXARGS -output-directory=./tmp/out_$LANG tmp/src_$LANG/iuf-rulebook.tex
    # remove -quiet if the build is failing, to figure out why
    mv tmp/out_$LANG/iuf-rulebook.pdf pdf/iuf-rulebook-$BRANCH-$LANG.pdf
done
