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
DIFFTEX=$(SRCDIR)/$(PROJECT)-$(BRANCH)-diff-$(DIFFBRANCH).tex

# LaTeX
LATEXARGS= -output-directory=$(OUTDIR) -interaction=batchmode -file-line-error

# Help
# target : normal-prerequesites | order-only-prerequesites
# 	command
#
# updates in order-only-prerequesites do not trigger rebuilds
#
# target variable: $@
# dependency variable: $<

rulebook: $(BUILDDIR)/$(PROJECT)-$(BRANCH).pdf

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

$(BUILDDIR)/$(PROJECT)-$(BRANCH)-$(LANG).pdf:

# DIFFBRANCH needs to be passed externally
# TODO: make diff -> should produce all diffs from ./diff-branches

diff: $(BUILDDIR)/$(PROJECT)-$(BRANCH)-diff-$(DIFFBRANCH).pdf

$(BUILDDIR)/$(PROJECT)-$(BRANCH)-diff-$(DIFFBRANCH).pdf: | setup
	# building diff against branch $(DIFFBRANCH)
	rcs-latexdiff --no-pdf --no-open --verbose -D -vo $(DIFFTEX) $(MAINTEX) $(DIFFBRANCH) HEAD; \
	TEXDIR=$(SRCDIR); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $(DIFFTEX); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS)            $(DIFFTEX); \
	mv $(OUTDIR)/`basename $@` $(BUILDDIR); \
	cat $(OUTDIR)/$(PROJECT)-$(BRANCH)-diff-$(DIFFBRANCH).log

$(BUILDDIR)/$(PROJECT)-$(BRANCH)-diff-$(DIFFBRANCH)-$(LANG).pdf:



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
	rm -rf $(SRCDIR)/$(PROJECT)-* # TODO ?


















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
