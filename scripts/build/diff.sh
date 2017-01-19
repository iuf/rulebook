#/bin/bash -e

DIFFBRANCH=$1
BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ ! $DIFFBRANCH ]]; then
    echo "usage: $0 DIFFBRANCH"
    exit 1
fi

mkdir -p tmp

latexdiff-vc --git --so --flatten --packages="hyperref" --force --exclude-textcmd="part,chapter,section,subsection,subsubsection" -r $DIFFBRANCH -r $BRANCH src/iuf-rulebook.tex
mv src/iuf-rulebook-diff$DIFFBRANCH-$BRANCH.tex tmp/iuf-rulebook-$BRANCH-diff-$DIFFBRANCH.tex

scripts/build/diff-pdf.sh tmp iuf-rulebook-$BRANCH-diff-$DIFFBRANCH
