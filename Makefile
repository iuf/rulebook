PROJECT=iuf-rulebook
TRANSIFEXPROJECT=rulebook.master
IGNOREFORTRANSLATION=preamble

REPO=.

SRCDIR=$(REPO)/src
OUTDIR=$(REPO)/out
PODIR=$(REPO)/po

SRCFILES=$(shell find $(SRCDIR) -type f)

OLDCOMMIT=2013
NEWCOMMIT=travis
DIFFNAME=$(PROJECT)-diff-$(OLDCOMMIT)-$(NEWCOMMIT)
BRANCHNAME="current"

FILEPREFIX=$(PROJECT)-$(BRANCHNAME)

PO4ACHARSETS=-M Utf-8 -L Utf-8
LATEXARGS= -output-directory=$(OUTDIR) -interaction=batchmode -file-line-error

.DELETE_ON_ERROR:

pdf: $(OUTDIR)/$(FILEPREFIX).pdf

$(OUTDIR)/$(FILEPREFIX).pdf $(OUTDIR)/$(PROJECT).aux $(OUTDIR)/$(PROJECT).idx: $(SRCDIR)/$(PROJECT).tex $(SRCFILES) | $(OUTDIR)
	TEXDIR=$(SRCDIR); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $< 2>&1 | tee $(OUTDIR)/`basename $<`.log && \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS)            $< 2>&1 | tee $(OUTDIR)/`basename $<`.log; \
	mv $(OUTDIR)/$(PROJECT).pdf $(OUTDIR)/$(FILEPREFIX).pdf

diff: | $(OUTDIR)
	rcs-latexdiff --no-pdf --no-open -vo $(SRCDIR)/$(DIFFNAME).tex src/$(PROJECT).tex $(OLDCOMMIT) $(NEWCOMMIT)
	$(MAKE) $(OUTDIR)/$(DIFFNAME).pdf

translated: update-translation | $(OUTDIR)
	# build pdfs for all translations
	# from earlier generated translated src/iuf-rulebook-$LANG.tex
	for file in `find $(SRCDIR)/$(PROJECT)-*.tex`; do \
		$(MAKE) $(OUTDIR)/`basename $$file | sed 's/\.tex$$/\.pdf/'`; \
	done

update-translation: $(PODIR)/template.pot
	tx push --source # upload new strings to transifex
	tx pull --all # download all translated strings from transifex
	# generate language-dependent tex files e.g. src/iuf-rulebook-de_DE.tex
	TEXINPUTS=$(SRCDIR): po4a --variable repo=$(REPO) $(PO4ACHARSETS) $(REPO)/po4a.cfg

$(PODIR)/template.pot: $(SRCFILES) po4a.cfg | $(PODIR)
	TEXINPUTS=$(SRCDIR): po4a-gettextize -f latex -m $(SRCDIR)/$(PROJECT).tex $(PO4ACHARSETS) -o 'exclude_include=$(IGNOREFORTRANSLATION)' -p $(PODIR)/template.pot


$(OUTDIR):
	mkdir -p $(OUTDIR)

$(PODIR):
	mkdir -p $(PODIR)


clean:
	rm -rf $(OUTDIR)
	rm -rf $(PODIR)
	rm -rf $(SRCDIR)/$(PROJECT)-*
