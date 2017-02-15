#!/usr/bin/env bash
set -e # POSIX version of bash -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-hvct]
Build IUF Rulebook for the current branch.

    -h          display this help and exit
    -v          verbose (do not run latexmk quietly)
    -c          clean mode: clean up all latex temp files before building pdf
    -t          travis mode: do some things if running on travis ci
EOF
}

# Defaults variables:

VERBOSE="" # Defaults to not verbose script
CLEAN=""
TRAVIS=1


OPTIND=1 # Safe code
while getopts :hvct opt; do
  case $opt in
    h)
        show_help
        exit 0
        ;;
    v)  VERBOSE="-v" # If verbose, give me some more information when I run this script
        ;;
    c)  CLEAN="-c"
        ;;
    t)  TRAVIS=0
        ;;
    \?)
        show_help >&2
        exit 1
        ;;
  esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

function finish_script {
  if [[ $TRAVIS -eq 0 ]]; then
      echo -en 'travis_fold:end:build_rulebook\\r'
  fi
  exit
}

trap finish_script INT TERM SIGHUP SIGINT SIGTERM

if [[ $TRAVIS -eq 0 ]]; then
    echo -en 'travis_fold:start:build_rulebook\\r'
    echo ""
    echo "Building rulebook pdf"
fi

scripts/build/pdf.sh $VERBOSE $CLEAN -o iuf-rulebook-$BRANCH.pdf -s src iuf-rulebook.tex

finish_script
