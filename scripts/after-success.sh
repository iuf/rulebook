#!/bin/bash

ls -l out
ls -l pdf
ls -l src

mkdir upload
mv pdf/*.pdf upload
ncftpput -u $FTPUSER -p $FTPPASS -R unicycling.org /temp upload/
