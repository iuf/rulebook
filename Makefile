PROJECT='iuf-rulebook'

SRCDIR='src'
OUTDIR='out'
OLDCOMMIT='HEAD~1'
NEWCOMMIT='HEAD'


LATEXARGS= -output-directory=$(OUTDIR) -interaction=nonstopmode -file-line-error

all:
	mkdir -p $(OUTDIR)
	TEXDIR=$(SRCDIR); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $$TEXDIR/$(PROJECT).tex 2>&1 | tee $(OUTDIR)/$(PROJECT).tex.log && \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) $$TEXDIR/$(PROJECT).tex 2>&1 | tee $(OUTDIR)/$(PROJECT).tex.log; \

diff:
	mkdir -p $(OUTDIR)
	rcs-latexdiff -o $(OUTDIR)/diff.tex --clean src/iuf-rulebook.tex $(OLDCOMMIT) $(NEWCOMMIT)
	TEXDIR=$(SRCDIR); \
	pdflatex $(LATEXARGS) -draftmode $(OUTDIR)/diff.tex 2>&1 | tee $(OUTDIR)/diff.tex.log && \
	pdflatex $(LATEXARGS) $(OUTDIR)/diff.tex 2>&1 | tee $(OUTDIR)/diff.tex.log; \


clean:
	rm -rf $(OUTDIR)
