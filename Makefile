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

.DEFAULT_GOAL := help # make help is default

.PHONY: help # required for the built-in documentation provided by make help


#
# PUBLIC API
#
# See: https://github.com/iuf/rulebook/wiki/Build-&-Deploy
#
################################################################################

# make PARA1=1 PARA2=ABC.c
# FOO ?= bar #sets FOO to bar only if FOO has not been set yet


#
# make rulebook
#
# build the rulebook pdf
rulebook: ## The most basic option: Creates the IUF Rulebook with the current branch name amended to the filename.
		scripts/build/rulebook.sh


#
# make diff
#
# output: pdf/iuf-rulebook-<version>-diff-<branch>.pdf
#

diff: ## Creates an output pdf that compares the current rulebook with the branches listed in the diff-branches file
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
translation: ## Creates translated versions of the current rulebook using translations from Transifex
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

clean: ## Removes all files created by the build process, except any output pdfs
	rm -rf tmp src/*/*diff*.tex src/*diff*.tex

clean-all: ## Removes all files created by the build process, including the output pdfs
	rm -rf pdf tmp src/*/*diff*.tex src/*diff*.tex

# Adds documentation text for any target
# Use on the line where the target is declared with double hash (##)
help: ## Shows this documentation
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


# put this somewhere when we're ready
#echo -n "" > toggles.tex #empties the toggles file, so that new things can be added
#echo "\\\\togglefalse{long}" > toggles.tex
