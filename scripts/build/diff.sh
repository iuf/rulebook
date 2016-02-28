#/bin/bash -e

DIFFBRANCH=$1
BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ ! $DIFFBRANCH ]]; then
    echo "usage: $0 DIFFBRANCH"
    exit 1
fi

mkdir -p tmp

cp --archive --no-target-directory src tmp/src_diff-$DIFFBRANCH
latexdiff-vc --git --flatten --force --exclude-textcmd="part,chapter,section,subsection,subsubsection" --revision=$DIFFBRANCH src/iuf-rulebook.tex
mv src/iuf-rulebook-diff$DIFFBRANCH.tex src/iuf-rulebook-$BRANCH-diff-$DIFFBRANCH.tex

scripts/build/pdf.sh tmp/src_diff-$DIFFBRANCH $BRANCH-diff-$DIFFBRANCH
