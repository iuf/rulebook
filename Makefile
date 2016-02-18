# General
PROJECT=iuf-rulebook

# Translation
TRANSIFEXPROJECT=rulebook.master
IGNOREFORTRANSLATION=preamble
PO4ACHARSETS=-M Utf-8 -L Utf-8

# Paths
REPO=.
SRCDIR=$(REPO)/src
OUTDIR=$(REPO)/out
BUILDDIR=$(REPO)/pdf
PODIR=$(REPO)/po

# Dynamic
SRCFILES=$(shell find $(SRCDIR) -type f)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
DIFFBRANCH=$(shell head -1 diff-branches)
MAINTEX=$(SRCDIR)/$(PROJECT).tex

# LaTeX
LATEXARGS= -output-directory=$(OUTDIR) -interaction=batchmode -file-line-error -halt-on-error

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
rulebook: $(BUILDDIR)/$(PROJECT)-$(BRANCH).pdf

#
# make diff
#
# build diff against branch $(DIFFBRANCH)
#
# Parameters:
#   DIFFBRANCH = the branch you want to diff against
diff: $(BUILDDIR)/$(PROJECT)-$(BRANCH)-diff-$(DIFFBRANCH).pdf

#
# make diff-all
#
# build all diffs against branches found in file `diff-branches`
diff-all: $(shell sed "s/\(.*\)/.\/$(REPO)\/pdf\/$(PROJECT)-$(BRANCH)-diff-\1\.pdf/g" diff-branches)

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
translated: $(PODIR)/template.pot | setup
	tx push --source # upload new strings to transifex
	tx pull --all # download all translated strings from transifex
	# generate language-dependent tex files e.g. src/iuf-rulebook-master-de_DE.tex
	TEXINPUTS=$(SRCDIR): po4a --variable branch=$(BRANCH) --variable repo=$(REPO) $(PO4ACHARSETS) $(REPO)/config/po4a.cfg
	# build pdfs for all translations
	for translated_tex in `find $(SRCDIR)/$(PROJECT)-*.tex`; do \
		translated_pdf=$(OUTDIR)/`basename $$translated_tex | sed 's/\.tex$$/\.pdf/'` && \
		translated_log=$(OUTDIR)/`basename $$translated_tex | sed 's/\.tex$$/\.log/'` && \
		echo $$translated_tex && \
		TEXDIR=$(SRCDIR) && \
		TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $$translated_tex && \
		TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS)            $$translated_tex && \
		mv $$translated_pdf $(BUILDDIR) && \
		mv $$translated_tex $(OUTDIR) && \
		cat $$translated_log; \
	done

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
#  $(OUTDIR)/$(PROJECT)-$(BRANCH).aux $(OUTDIR)/$(PROJECT)-$(BRANCH).idx
$(BUILDDIR)/$(PROJECT)-$(BRANCH).pdf: $(SRCFILES) | setup
	# building $@ from $(MAINTEX)
	TEXDIR=$(SRCDIR); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $(MAINTEX); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS)            $(MAINTEX); \
	mv $(OUTDIR)/$(PROJECT).pdf $(BUILDDIR)/$(PROJECT)-$(BRANCH).pdf; \
	cat $(OUTDIR)/$(PROJECT).log


#
# make diff
#
# output: iuf-rulebook-<version>-diff-<branch>.pdf
#
$(BUILDDIR)/$(PROJECT)-$(BRANCH)-diff-%.pdf: | setup
	# building diff against branch $*
	latexdiff-vc --git --flatten --force --exclude-textcmd="part,chapter,section,subsection,subsubsection" -r $* $(MAINTEX); \
	mv $(SRCDIR)/$(PROJECT)-diff$*.tex $(SRCDIR)/$(PROJECT)-$(BRANCH)-diff-$*.tex; \
	TEXDIR=$(SRCDIR); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $(SRCDIR)/$(PROJECT)-$(BRANCH)-diff-$*.tex; \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS)            $(SRCDIR)/$(PROJECT)-$(BRANCH)-diff-$*.tex; \
	mv $(OUTDIR)/`basename $@` $(BUILDDIR); \
	mv $(SRCDIR)/$(PROJECT)-$(BRANCH)-diff-$*.tex $(OUTDIR); \
	cat $(OUTDIR)/$(PROJECT)-$(BRANCH)-diff-$*.log


#
# make translation
#
# output: iuf-rulebook-<version>-<locale>.pdf
#
$(BUILDDIR)/$(PROJECT)-$(BRANCH)-%.pdf: $(SRCDIR)/$(PROJECT)-$(BRANCH)-%.tex | $(OUTDIR) setup
	# building for language $*
	TEXDIR=$(SRCDIR); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $(SRCDIR)/$(PROJECT)-$(BRANCH)-$*.tex; \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS)            $(SRCDIR)/$(PROJECT)-$(BRANCH)-$*.tex; \
	mv $(OUTDIR)/`basename $@` $(BUILDDIR); \
	mv $(SRCDIR)/$(PROJECT)-$(BRANCH)-$*.tex $(OUTDIR); \
	cat $(OUTDIR)/$(PROJECT)-$(BRANCH)-$*.log


#
# locale preparation
# loads strings from transifex and turns them into tex files
#
# output: iuf-rulebook-<version>-<locale>.tex
#
$(SRCDIR)/$(PROJECT)-$(BRANCH)-%.tex: $(PODIR)/template.pot
	tx push --source # upload new strings to transifex
	tx pull --language=$* # download all translated strings for language $* from transifex
	# generate language-dependent tex files e.g. src/iuf-rulebook-master-de_DE.tex
	TEXINPUTS=$(SRCDIR): po4a --variable branch=$(BRANCH) --variable repo=$(REPO) $(PO4ACHARSETS) $(REPO)/config/po4a.cfg


#
# transifex preparation
# generates strings from tex files
#
# output: template.pot
#
$(PODIR)/template.pot: $(SRCFILES) config/po4a.cfg | $(PODIR) $(wildcard $(SRCDIR)/$(PROJECT)-$(BRANCH)-*.tex)
	# extract strings from latex into po/template.pot
	TEXINPUTS=$(SRCDIR): po4a-gettextize -f latex -m $(SRCDIR)/$(PROJECT).tex $(PO4ACHARSETS) -o 'exclude_include=$(IGNOREFORTRANSLATION)' -p $(PODIR)/template.pot


#
# Setup tasks
#
setup: | $(OUTDIR) $(BUILDDIR) $(PODIR)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(OUTDIR):
	mkdir -p $(OUTDIR)

$(PODIR):
	mkdir -p $(PODIR)


clean:
	rm -rf $(OUTDIR)
	rm -rf $(BUILDDIR)
	rm -rf $(PODIR)
	rm -rf $(SRCDIR)/$(PROJECT)-*


















# NAME_DIFF=$(PROJECT)-diff-$(BRANCH)-$(NEWCOMMIT)
# NAME=$(PROJECT)-$(BRANCH)

# FILEPREFIX=$(PROJECT)-$(BRANCHNAME)


# .DELETE_ON_ERROR:

# pdf: $(OUTDIR)/$(FILEPREFIX).pdf

# $(OUTDIR)/$(FILEPREFIX).pdf $(OUTDIR)/$(FILEPREFIX).aux $(OUTDIR)/$(FILEPREFIX).idx: $(SRCDIR)/$(FILEPREFIX).tex $(SRCFILES) | $(OUTDIR)
# 	TEXDIR=$(SRCDIR); \
# 	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $< 2>&1 | tee $(OUTDIR)/`basename $<`.log && \
# 	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS)            $< 2>&1 | tee $(OUTDIR)/`basename $<`.log; \
# 	mv $(OUTDIR)/$(PROJECT).pdf $(OUTDIR)/$(FILEPREFIX).pdf

# diff: | $(OUTDIR)
# 	rcs-latexdiff --no-pdf --no-open -vo $(SRCDIR)/$(DIFFNAME).tex src/$(PROJECT).tex $(OLDCOMMIT) $(NEWCOMMIT)
# 	$(MAKE) $(OUTDIR)/$(DIFFNAME).pdf

# translated: update-translation | $(OUTDIR)
# 	# build pdfs for all translations
# 	# from earlier generated translated src/iuf-rulebook-$LANG.tex
# 	for file in `find $(SRCDIR)/$(PROJECT)-*.tex`; do \
# 		$(MAKE) $(OUTDIR)/`basename $$file | sed 's/\.tex$$/\.pdf/'`; \
# 	done

# update-translation: $(PODIR)/template.pot
# 	tx push --source # upload new strings to transifex
# 	tx pull --all # download all translated strings from transifex TODO: -r RESOURCE / BRANCH
# 	# generate language-dependent tex files e.g. src/iuf-rulebook-de_DE.tex
# 	TEXINPUTS=$(SRCDIR): po4a --variable repo=$(REPO) $(PO4ACHARSETS) $(REPO)/po4a.cfg

# $(PODIR)/template.pot: $(SRCFILES) po4a.cfg | $(PODIR)
# 	TEXINPUTS=$(SRCDIR): po4a-gettextize -f latex -m $(SRCDIR)/$(PROJECT).tex $(PO4ACHARSETS) -o 'exclude_include=$(IGNOREFORTRANSLATION)' -p $(PODIR)/template.pot
