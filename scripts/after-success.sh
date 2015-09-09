#!/bin/bash

mkdir upload
mv out/*.pdf upload
ncftpput -u $FTPUSER -p $FTPPASS -R unicycling.org /temp upload/
