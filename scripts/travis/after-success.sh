#!/usr/bin/env bash
set -e # POSIX version of bash -e

ls -l pdf

mkdir upload

mv pdf/*.pdf upload

ncftpput -u $FTPUSER -p $FTPPASS -R unicycling.org /temp upload/
