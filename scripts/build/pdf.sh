#!/usr/bin/env bash
set -e # POSIX version of bash -e

# TODO: add preview option to latexmk and pass it up the line ("-pv")
# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-hvc] [-s SRCDIR] [-o OUTFILE] FILE.tex
Run latexmk on FILE.

    -h          display this help and exit
    -s SRCDIR   where TEXINPUTS should be located, defaults to 'src'
    -o OUTFILE  output file name, defaults to the input name
    -v          verbose (do not run latexmk quietly)
    -c          clean mode: clean up all latex temp files before building pdf
    FILE        input tex
EOF
}

# Defaults variables:
OUTDIR="pdf"
SRC='src'
QUIET="-quiet" # Defaults to quiet mode for latexmk
VERBOSE=1 # Defaults to not verbose script
OUT=""
CLEAN=""


OPTIND=1 # Safe code
while getopts :hvcs:o: opt; do
  case $opt in
    h)
        show_help
        exit 0
        ;;
    v)  QUIET="" # If verbose, don't print quiet in latexmk args
        VERBOSE=0 # If verbose, give me some more information when I run this script
        ;;
    c)  CLEAN="-gg"
        ;;
    o)  OUT=$OPTARG
        ;;
    s)  SRC=$OPTARG
        ;;
    \?)
        show_help >&2
        exit 1
        ;;
  esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

#Set input variable, with good error logic:
if [[ $# -eq 0 ]]; then
  echo "Error: Input file not supplied"
  echo
  show_help
  exit 1
elif [[ $# -eq 1 ]]; then
  IN=$1
else
  echo "Error: Too many arguments"
  echo
  show_help
  exit 1
fi

verbose_cmd() {
    # append 'verbose_cmd' before any command and it's output is silenced unless verbose is true
    if [[ $VERBOSE -eq 1 ]]; then
        "$@" > /dev/null
    else
        "$@"
    fi
}

function clean_up {
  # Perform program exit housekeeping
  mkdir -p tmp/latexmk
  rsync -az --remove-source-files --exclude '*.pdf' $OUTDIR/ tmp/latexmk/ # move anything that's not a pdf

  rm src/gitinfo2.sty
  rm src/gitexinfo.sty
  rm ./gitinfo2.sty
  rm ./gitexinfo.sty
  echo
  echo "Cleaning up after latexmk..."
  exit
}

trap clean_up INT TERM SIGHUP SIGINT SIGTERM

# install gitinfo for local builds
cp -a dependencies/gitinfo2/* src
cp -a dependencies/gitinfo2/* .
./scripts/install-git-hooks.sh > /dev/null

OUT=$(echo $OUT | sed -e "s~\(.*\)\.pdf~\1~") # remove pdf extention from output file name if it's there, so that latexmk can use it as the basename

mkdir -p $OUTDIR # make outdir (default: pdf/) if it doesn't exist

if [[ -z "$OUT" ]]; then
  OUTARG="-outdir=$OUTDIR"
else
  OUTARG="-jobname=$OUTDIR/$OUT"
fi

if [[ $VERBOSE -eq 0 ]]; then
  echo "Source: $SRC"
  echo "Input: $IN"
  echo "Input path: $SRC/$IN"
  echo "Output name: $OUT"
  echo "Quiet output: $QUIET"
  echo "Clean output: $CLEAN"
  echo "Outarg: $OUTARG"
  echo
  echo
  echo "Starting LaTeX Make:"
fi

TEXINPUTS=$SRC: openout_any=a verbose_cmd latexmk -pdf $QUIET $CLEAN -file-line-error -halt-on-error $OUTARG $SRC/$IN

clean_up
