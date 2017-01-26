#!/usr/bin/env bash
set -e # POSIX version of bash -e

DIFFBRANCH=$1
BRANCH=$(git rev-parse --abbrev-ref HEAD)
SRC=src
CHAPTERDIR=src/chapters
SHORTCHAPTERDIR=${CHAPTERDIR##src/} # remove src/ from the start of CHAPTERDIR
CHAPTERS=$(ls $CHAPTERDIR | grep ".*\.tex$")

LATEXARGS="-file-line-error -halt-on-error"
EXCLUDE_TEXTCMDS="part,chapter,section,subsection,subsubsection,iftoggle,comment2016" # for latexdiff

function clean_up {
  # Perform program exit housekeeping
  if [ -d "tmp/src_original" ]; then
   rsync -a  tmp/src_original/ src #put back original on completion or error
   echo 
   echo "Cleaning up..."
   rm -rf tmp/src_original
  fi
  exit
}

trap clean_up INT TERM SIGHUP SIGINT SIGTERM

if [[ ! $DIFFBRANCH ]]; then
    echo "usage: $0 DIFFBRANCH"
    exit 1
fi

# setup diretory structure as needed:
mkdir -p pdf
mkdir -p tmp/src_original/
mkdir -p tmp/src_diff_$DIFFBRANCH/$SHORTCHAPTERDIR
mkdir -p tmp/out_diff_$DIFFBRANCH

rsync -a  src/ tmp/src_original # copy original source before starting changes

echo "Starting find and replace changes for diff..."

# replace iftoggles that have a true and a false option with only the true option
sed -i.bak 's~^[[:blank:]]*\\iftoggle{[[:alnum:]_][[:alnum:]_]*}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}~\\input{\1}~' $CHAPTERDIR/*.tex
#replace iftoggles that only have a true option
sed -i.bak 's~^[[:blank:]]*\\iftoggle{[[:alnum:]_][[:alnum:]_]*}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}{}~\\input{\1}~' $CHAPTERDIR/*.tex

#TODO: hockey img

# the -i.bak is required so SED works on both OSX and Linux (BSD and GNU sed)
rm -f $CHAPTERDIR/*.bak # because of this, we have to delete the .bak files after

echo "Done"

# create tex diff files for each chapter:
for CHAPTER in $CHAPTERS; do
    echo $CHAPTER
    SLUG=$(echo $CHAPTER | cut -f 1 -d '.')
    latexdiff-vc --git --so --flatten  --force -r $DIFFBRANCH $CHAPTERDIR/$CHAPTER
    # --exclude-textcmd=$EXCLUDE_TEXTCMDS
    mv -v $CHAPTERDIR/$SLUG-diff$DIFFBRANCH.tex tmp/src_diff_$DIFFBRANCH/$SHORTCHAPTERDIR/$SLUG.tex
done
# remember to do something about toggle include for std skills

# create title-page diff:
latexdiff-vc --git --so --force -r $DIFFBRANCH -r $BRANCH $SRC/titlepage.tex
mv -v $SRC/titlepage-diff$DIFFBRANCH-$BRANCH.tex tmp/src_diff_$DIFFBRANCH/titlepage.tex # move titlepage diff to tmp
rm -rf $SRC/titlepage-old* # remove tmp files created with latexdiff

# copy all source files to tmp except chapters (because they're already there):
rsync -az --ignore-existing --exclude $SHORTCHAPTERDIR src/ tmp/src_diff_$DIFFBRANCH/
# --ignore-existing because the diff'ed titlepage is already in the tmp diff directory

# compile the actual pdf and put it in the pdf dir:
TEXINPUTS=tmp/src_diff_$DIFFBRANCH: latexmk -pdf -quiet $LATEXARGS -output-directory=tmp/out_diff_$DIFFBRANCH tmp/src_diff_$DIFFBRANCH/iuf-rulebook.tex
# remove -quiet if the build is failing to figure out where
mv tmp/out_diff_$DIFFBRANCH/iuf-rulebook.pdf pdf/iuf-rulebook-$BRANCH-diff-$DIFFBRANCH.pdf

clean_up

