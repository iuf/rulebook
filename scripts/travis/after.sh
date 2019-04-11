#!/usr/bin/env bash
set -e # POSIX version of bash -e

mkdir -p upload

if ls pdf/*.pdf >/dev/null 2>&1; then cp pdf/*.pdf upload; fi # only copy files if they exist

# Upload the log files too, and depending on how far the script gets, there are two possible locations:
if ls pdf/*.log >/dev/null 2>&1; then cp pdf/*.log upload; fi # only copy files if they exist
if ls tmp/latexmk/*.log >/dev/null 2>&1; then cp tmp/latexmk/*.log upload; fi # only copy files if they exist

echo "Files:"
ls -1 upload
echo
echo "Uploading files..."
ncftpput -u $FTPUSER -p $FTPPASS -R elbert.dreamhost.com /rulebook.scott-wilton.com upload/*
echo "Done."
