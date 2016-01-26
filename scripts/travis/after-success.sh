#!/bin/bash

ls -l out
ls -l pdf
ls -l src

mkdir upload
mv pdf/*.pdf upload
mv src/iuf-rulebook* upload
mv out/*.log upload
ncftpput -u $FTPUSER -p $FTPPASS -R unicycling.org /temp upload/
