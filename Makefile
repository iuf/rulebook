SRCFILES=$(shell find src -type f)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

# Help
# target : normal-prerequesites | order-only-prerequesites
# 	command
#
# updates in order-only-prerequesites do not trigger rebuilds
#
# target variable: $@
# wildcard in target: $*
# dependency variable: $<




#
# PUBLIC API
#
# See: https://github.com/iuf/rulebook/wiki/Build-&-Deploy
#
################################################################################


#
# make rulebook
#
# build the rulebook pdf
rulebook: pdf/iuf-rulebook-$(BRANCH).pdf


#
# make diff
#
# output: pdf/iuf-rulebook-<version>-diff-<branch>.pdf
#

diff:
	scripts/build/diff-all.sh

#
# make translation
#
# Generates a translated version of the rulebook
#
# Parameters:
#   LOCALE = the language-tag for the translated version
#
# TODO: change translated to translation ?
# TODO: make translation-all task
translation: setup
	scripts/build/translation.sh
# TODO
# make tailored
#
# Parameters:
#   AUDIENCE = Takes a comma separated list of arguments. Valid items: competitor, organizer
#   PART = Takes a comma separated list of arguments. Valid items: TODO !
#   LOCALE = the language-tag for a translated version of the above
#


#
# PRIVATE API
#
# tasks used internally by public tasks
#
################################################################################

#
# make rulebook
#
# output: iuf-rulebook-<version>.pdf
#
pdf/iuf-rulebook-$(BRANCH).pdf: $(SRCFILES)
	scripts/build/pdf.sh src $(BRANCH)

clean:
	rm -rf pdf tmp
