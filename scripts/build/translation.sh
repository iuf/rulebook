#!/usr/bin/env bash
set -e # POSIX version of bash -e

echo "Building translation pdf(s)"

BRANCH=$(git rev-parse --abbrev-ref HEAD)

PO4ACHARSETS="--master-charset Utf-8 --localized-charset Utf-8"

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-hvcd]
Build the translated IUF Rulebook for the current branch with traslation from Transifex.

    -h          display this help and exit
    -v          verbose (do not run latexmk quietly)
    -c          clean mode: clean up all latex temp files before building pdf
    -d          debug mode: only translate the first chapter, because its faster
EOF
}

# Defaults variables:
VERBOSE_FLAG="" # Defaults to not verbose script
VERBOSE=1
CLEAN_FLAG=""
DEBUG=1


OPTIND=1 # Safe code
while getopts :hvcd opt; do
  case $opt in
    h)
        show_help
        exit 0
        ;;
    v)  VERBOSE_FLAG="-v" # If verbose, give me some more information when I run this script
        VERBOSE=0
        ;;
    c)  CLEAN_FLAG="-c"
        ;;
    d)  DEBUG=0
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

if [[ $DEBUG -eq 0 ]]; then
    rm -rf tmp # clean up tmp dir incase the problem is there
fi

rm -rf .tx
echo "Configuring Transifex..."
verbose_cmd tx init --host=https://www.transifex.com
echo "Done."

mkdir -p tmp
mkdir -p pdf
mkdir -p tmp/src_translation

rsync -az src/ tmp/src_translation/

CHAPTERDIR=tmp/src_translation/chapters
cp config/base_strings.tex $CHAPTERDIR/00_base_strings.tex # copy the basic strings to the tmp dir too, so we can upload it
CHAPTERS=$(ls $CHAPTERDIR | grep ".*\.tex$")

if [[ $DEBUG -eq 0 ]]; then
    CHAPTERS="01_general.tex" # only translate the first chater
fi

# replace iftoggles that have a true and a false option
sed -i.bak 's~^[[:blank:]]*\\iftoggle{[[:alnum:]_][[:alnum:]_]*}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}~\\input{\1}\\input{\2}~' $CHAPTERDIR/*.tex
#replace iftoggles that only have a true option
sed -i.bak 's~^[[:blank:]]*\\iftoggle{[[:alnum:]_][[:alnum:]_]*}{\\input{\([[:alnum:]_\/][[:alnum:]_\/]*\)}}{}~\\input{\1}~' $CHAPTERDIR/*.tex

# the -i.bak is required so SED works on both OSX and Linux (BSD and GNU sed)
rm -f $CHAPTERDIR/*.bak # because of this, we have to delete the .bak files after


# extract translation templates for each chapter and write them to transifex config file (.tx/config)
# (for current branch)
echo "Extracting Translation Templates..."
for CHAPTER in $CHAPTERS; do
    SLUG=$(echo $CHAPTER | sed -e "s/[0-9][0-9]_\(.*\)\.tex/\1/")
    verbose_cmd echo $SLUG
    verbose_cmd echo $CHAPTERDIR/$CHAPTER
    echo -e '0r config/po4a-escape.tex\nw' | ed -s $CHAPTERDIR/$CHAPTER # add po4a escape commands to the beginning of each chapter
    TEXINPUTS=$CHAPTERDIR verbose_cmd po4a-gettextize --format latex --master $CHAPTERDIR/$CHAPTER --po tmp/po/${SLUG}/template.pot $PO4ACHARSETS

    sed -i.bak 's~charset=CHARSET~charset=UTF-8~' tmp/po/${SLUG}/template.pot # fix charset because po4a isn't setting it correctly

    verbose_cmd tx set --auto-local --resource=rulebook-$BRANCH.$SLUG "tmp/po/${SLUG}/<lang>.po" --type PO --source-lang en --source-file tmp/po/${SLUG}/template.pot --execute
done
echo "Done."

# upload all tempates to transifex
echo "Pushing to transifex..."
verbose_cmd tx push --source
echo "Done."
# download all translated strings from transifex
echo "Pulling from transifex..."
verbose_cmd tx pull --all #TODO: -- mode reviewed
echo "Done."

# extracts the list of languages by looking at one chapter's po-files
LANGUAGES=$(ls tmp/po/$(ls tmp/po | head -1)/*.po | xargs -n1 basename | sed "s/\\.po$//")

verbose_cmd echo "Languages:"
verbose_cmd echo $LANGUAGES

for LANG in $LANGUAGES; do
    mkdir -p tmp/src_$LANG
    rsync -a tmp/src_translation/ tmp/src_$LANG
done

verbose_cmd ls tmp
verbose_cmd ls tmp/src_translation/chapters

for CHAPTER in $CHAPTERS; do
    SLUG=$(echo $CHAPTER | sed -e "s/[0-9][0-9]_\(.*\)\.tex/\1/")

    TEXINPUTS=./tmp/src_translation/chapters po4a --variable chapter_file=$CHAPTER --variable chapter_slug=$SLUG $PO4ACHARSETS config/po4a.cfg
done > /dev/null

#TODO: language specific titlepage and preamble

for LANG in $LANGUAGES; do
    echo "Building pdf for $LANG"
    scripts/build/pdf.sh $VERBOSE_FLAG $CLEAN_FLAG -s tmp/src_$LANG -o iuf-rulebook-$BRANCH-$LANG.pdf iuf-rulebook.tex
done
