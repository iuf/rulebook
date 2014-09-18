PROJECT=iuf-rulebook
TRANSIFEXPROJECT=rulebook.master
IGNOREFORTRANSLATION=preamble

REPO=.

SRCDIR=$(REPO)/src
OUTDIR=$(REPO)/out
PODIR=$(REPO)/po

SRCFILES=$(shell find $(SRCDIR) -type f)

OLDCOMMIT=2012
NEWCOMMIT=master
DIFFNAME=$(PROJECT)-diff-$(OLDCOMMIT)-$(NEWCOMMIT)

PO4ACHARSETS=-M Utf-8 -L Utf-8
LATEXARGS= -output-directory=$(OUTDIR) -interaction=nonstopmode -file-line-error

.DELETE_ON_ERROR:

pdf: $(OUTDIR)/$(PROJECT).pdf

$(OUTDIR)/%.pdf $(OUTDIR)/%.aux $(OUTDIR)/%.idx: $(SRCDIR)/%.tex $(SRCFILES) | $(OUTDIR) 
	TEXDIR=$(SRCDIR); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $< 2>&1 | tee $(OUTDIR)/`basename $<`.log && \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS)            $< 2>&1 | tee $(OUTDIR)/`basename $<`.log; \

diff: | $(OUTDIR)
	rcs-latexdiff -vo $(SRCDIR)/$(DIFFNAME).tex src/$(PROJECT).tex $(OLDCOMMIT) $(NEWCOMMIT)
	$(MAKE) $(OUTDIR)/$(DIFFNAME).pdf

translated: update-translation | $(OUTDIR)
	for file in `find $(SRCDIR)/$(PROJECT)-*.tex`; do \
		$(MAKE) $(OUTDIR)/`basename $$file | sed 's/\.tex$$/\.pdf/'`; \
	done

update-translation: $(PODIR)/template.pot
	tx push --source
	tx pull --all
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

