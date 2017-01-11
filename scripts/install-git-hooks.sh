#!/bin/sh -e
cp -a scripts/git-hooks/* .git/hooks/
./.git/hooks/post-checkout
echo "Git Hooks installed."

