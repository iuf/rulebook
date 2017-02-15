#!/usr/bin/env bash
set -e # POSIX version of bash -e

show_help() {
cat << EOF
Usage: ${0##*/} [-hvcd]
Build the IUF Rulebook difference pdf comparing the current branch all branches in diff-branches.

    -h     display this help and exit
    -v     verbose (do not run latexmk quietly)
    -c     clean mode: clean up all latex temp files before building pdf
    -d     debug mode: only diff the first chapter and only diff against the first diff-branch, because its faster
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

if [[ $DEBUG -eq 0 ]]; then
  DIFFBRANCHES=$(head -1 diff-branches)
else
  DIFFBRANCHES=$(cat diff-branches)
fi

if [[ $VERBOSE -eq 0 ]]; then
  echo "Diffing on branches:"
  echo $DIFFBRANCHES
fi

for DIFFBRANCH in $DIFFBRANCHES; do
    scripts/build/diff.sh $VERBOSE_FLAG $CLEAN_FLAG $DEBUG_FLAG $DIFFBRANCH
done
