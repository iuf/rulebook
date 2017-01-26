#!/usr/bin/env bash
set -e # POSIX version of bash -e

make rulebook
scripts/build/diff-all.sh
scripts/build/translation.sh
