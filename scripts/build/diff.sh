#!/usr/bin/env bash
set -e # POSIX version of bash -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)
SRC=src
CHAPTERDIR=src/chapters
SHORTCHAPTERDIR=${CHAPTERDIR##src/} # remove src/ from the start of CHAPTERDIR
CHAPTERS=$(ls $CHAPTERDIR | grep ".*\.tex$")

EXCLUDE_TEXTCMDS="part,chapter,section,subsection,subsubsection,iftoggle,comment2016" # for latexdiff

function clean_up {
  # Perform program exit housekeeping
  echo
  echo "Cleaning up after $DIFFBRANCH diff build..."
  if [ -d "tmp/src_original" ]; then
   rsync -a  tmp/src_original/ src #put back original on completion or error
   rm -rf tmp/src_original
  fi
  rm -rf src/*/*diff*.tex src/*diff*.tex # remove any diff tex files that might be left over from the diff build
  exit
}

trap clean_up INT TERM SIGHUP SIGINT SIGTERM

show_help() {
cat << EOF
Usage: ${0##*/} [-hvcd] DIFFBRANCH
Build the IUF Rulebook difference pdf comparing the current branch with DIFFBRANCH.

    -h      display this help and exit
    -v      verbose (do not run latexmk quietly)
    -c      clean mode: clean up all latex temp files before building pdf
    -d      debug mode: only diff the first chapter, because its faster
EOF
}

# Defaults variables:

VERBOSE_FLAG=""
VERBOSE=1
CLEAN_FLAG=""
DEBUG_FLAG=""
DEBUG=1


OPTIND=1 # Safe code
while getopts :hvcd opt; do
  case $opt in
    h)
        show_help
        exit 0
        ;;
    v)  VERBOSE_FLAG="-v"
        VERBOSE=0
        ;;
    c)  CLEAN_FLAG="-c"
        ;;
    d)  DEBUG_FLAG="-d"
        DEBUG=0
        ;;
    \?)
        show_help >&2
        exit 1
        ;;
  esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

verbose_cmd() {
    # append 'verbose_cmd' before any command and it's output is silenced unless verbose is true
    if [[ $VERBOSE -eq 1 ]]; then
        "$@" > /dev/null
    else
        "$@"
    fi
}

DIFFBRANCH=$1

if [[ $DEBUG -eq 0 ]]; then
  rm -rf tmp # clean up tmp dir incase the problem is there
  CHAPTERS="01_general.tex" # only translate the first chater
fi

# if [[ $VERBOSE -eq 0 ]]; then
#   echo "Diffing on branches:"
#   echo $DIFFBRANCHES
# fi

if [[ ! $DIFFBRANCH ]]; then
    echo "usage: $0 DIFFBRANCH"
    exit 1
fi

# setup diretory structure as needed:
mkdir -p pdf
mkdir -p tmp/src_original/
mkdir -p tmp/src_diff_$DIFFBRANCH/$SHORTCHAPTERDIR
mkdir -p tmp/out_diff_$DIFFBRANCH

#TODO: cp
rsync -a  src/ tmp/src_original # copy original source before starting changes

verbose_cmd echo "Starting find and replace changes for diff..."

# replace iftoggles that have a true and a false option with only the true option
sed -i.bak 's~^[[:blank:]]*\\iftoggle{[[:alnum:]_][[:alnum:]_]*}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}~\\input{\1}~' $CHAPTERDIR/*.tex
#replace iftoggles that only have a true option
sed -i.bak 's~^[[:blank:]]*\\iftoggle{[[:alnum:]_][[:alnum:]_]*}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}{}~\\input{\1}~' $CHAPTERDIR/*.tex

#TODO: hockey img

# the -i.bak is required so SED works on both OSX and Linux (BSD and GNU sed)
rm -f $CHAPTERDIR/*.bak # because of this, we have to delete the .bak files after

verbose_cmd echo "Done"


# create tex diff files for each chapter:
for CHAPTER in $CHAPTERS; do
    verbose_cmd echo "Diffing on chapter file: $CHAPTER"
    SLUG=$(echo $CHAPTER | cut -f 1 -d '.')
    verbose_cmd latexdiff-vc --git --so --flatten  --force -r $DIFFBRANCH $CHAPTERDIR/$CHAPTER
    # --exclude-textcmd=$EXCLUDE_TEXTCMDS
    verbose_cmd mv -v $CHAPTERDIR/$SLUG-diff$DIFFBRANCH.tex tmp/src_diff_$DIFFBRANCH/$SHORTCHAPTERDIR/$SLUG.tex
done
# TODO: remember to do something about toggle include for std skills

# create title-page diff:
verbose_cmd latexdiff-vc --git --so --force -r $DIFFBRANCH -r $BRANCH $SRC/titlepage.tex
verbose_cmd mv -v $SRC/titlepage-diff$DIFFBRANCH-$BRANCH.tex tmp/src_diff_$DIFFBRANCH/titlepage.tex # move titlepage diff to tmp
rm -rf $SRC/titlepage-old* # remove tmp files created with latexdiff

# copy all source files to tmp except chapters (because they're already there):
rsync -az --ignore-existing src/ tmp/src_diff_$DIFFBRANCH/ #***
# --ignore-existing because the diff'ed titlepage is already in the tmp diff directory

# add latexdiff preamble code to existing preamble:
cat dependencies/latexdiff-preamble.tex >> tmp/src_diff_"$DIFFBRANCH"/preamble.tex

# compile the actual pdf and put it in the pdf dir:
scripts/build/pdf.sh $VERBOSE_FLAG $CLEAN_FLAG -s tmp/src_diff_$DIFFBRANCH -o iuf-rulebook-$BRANCH-diff-$DIFFBRANCH.pdf iuf-rulebook.tex

clean_up
