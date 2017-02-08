#!/usr/bin/env bash
set -e # POSIX version of bash -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-hvc]
Build IUF Rulebook for the current branch.

    -h          display this help and exit
    -v          verbose (do not run latexmk quietly)
    -c          clean mode: clean up all latex temp files before building pdf
EOF
}

# Defaults variables:

VERBOSE="" # Defaults to not verbose script
CLEAN=""


OPTIND=1 # Safe code
while getopts :hvc opt; do
  case $opt in
    h)
        show_help
        exit 0
        ;;
    v)  VERBOSE="-v" # If verbose, give me some more information when I run this script
        ;;
    c)  CLEAN="-c" 
        ;;
    \?)
        show_help >&2
        exit 1
        ;;
  esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

echo "Building rulebook pdf" # for travis

scripts/build/pdf.sh $VERBOSE $CLEAN -o iuf-rulebook-$BRANCH.pdf -s src iuf-rulebook.tex
