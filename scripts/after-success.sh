#!/bin/bash

mkdir upload
mv pdf/*.pdf upload
ncftpput -u $FTPUSER -p $FTPPASS -R unicycling.org /temp upload/
