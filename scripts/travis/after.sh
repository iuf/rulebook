#!/usr/bin/env bash
set -e # POSIX version of bash -e

try_cp () { cp $1 $2 2>/dev/null || : ; } # try to copy files, but ignore errors if it doesn't work
ls -l pdf

mkdir -p upload

try_cp pdf/*.pdf upload

# Upload the log files too, and depending on how far the script gets, there are two possible locations:
try_cp pdf/*.log upload
try_cp tmp/latexmk/*.log upload

ncftpput -u $FTPUSER -p $FTPPASS -R unicycling.org /temp upload/
