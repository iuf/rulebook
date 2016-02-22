# Dynamic
SRCFILES=$(shell find src -type f)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
DIFFBRANCH=$(shell head -1 diff-branches)

# LaTeX
LATEXARGS= -output-directory=tmp/out -interaction=batchmode -file-line-error -halt-on-error

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
# build diff against branch $(DIFFBRANCH)
#
# Parameters:
#   DIFFBRANCH = the branch you want to diff against
diff: pdf/iuf-rulebook-$(BRANCH)-diff-$(DIFFBRANCH).pdf

#
# make diff-all
#
# build all diffs against branches found in file `diff-branches`
diff-all: $(shell sed "s/\(.*\)/.\/pdf\/iuf-rulebook-$(BRANCH)-diff-\1\.pdf/g" diff-branches)

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
#TODO: error when branch in filename != current branch, because we can only build the current one
#TODO: this rule is always rebuilding
#  $(OUTDIR)/iuf-rulebook-$(BRANCH).aux $(OUTDIR)/iuf-rulebook-$(BRANCH).idx
pdf/iuf-rulebook-$(BRANCH).pdf: $(SRCFILES) | setup
	# building $@ from src/iuf-rulebook.tex
	TEXINPUTS=src: pdflatex $(LATEXARGS) -draftmode src/iuf-rulebook.tex; \
	TEXINPUTS=src: pdflatex $(LATEXARGS)            src/iuf-rulebook.tex; \
	mv tmp/out/iuf-rulebook.pdf pdf/iuf-rulebook-$(BRANCH).pdf; \
	cat tmp/iuf-rulebook.log


#
# make diff
#
# output: iuf-rulebook-<version>-diff-<branch>.pdf
#
pdf/iuf-rulebook-$(BRANCH)-diff-%.pdf: | setup
	# building diff against branch $*
	latexdiff-vc --git --flatten --force --exclude-textcmd="part,chapter,section,subsection,subsubsection" -r $* src/iuf-rulebook.tex; \
	mv $(SRCDIR)/iuf-rulebook-diff$*.tex $(SRCDIR)/iuf-rulebook-$(BRANCH)-diff-$*.tex; \
	TEXDIR=$(SRCDIR); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $(SRCDIR)/iuf-rulebook-$(BRANCH)-diff-$*.tex; \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS)            $(SRCDIR)/iuf-rulebook-$(BRANCH)-diff-$*.tex; \
	mv $(OUTDIR)/`basename $@` pdf; \
	mv $(SRCDIR)/iuf-rulebook-$(BRANCH)-diff-$*.tex $(OUTDIR); \
	cat $(OUTDIR)/iuf-rulebook-$(BRANCH)-diff-$*.log



#
# Setup tasks
#
setup:
	mkdir -p tmp/out
	mkdir -p pdf


clean:
	rm -rf pdf tmp
