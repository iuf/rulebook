PROJECT='iuf-rulebook'

SRCDIR='src'
OUTDIR='out'

LATEXARGS= -output-directory=$(OUTDIR) -interaction=nonstopmode -file-line-error

all:
	mkdir -p $(OUTDIR)
	TEXDIR=$(SRCDIR); \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) -draftmode $$TEXDIR/$(PROJECT).tex 2>&1 | tee $(OUTDIR)/$(PROJECT).tex.log && \
	TEXINPUTS=$$TEXDIR: pdflatex $(LATEXARGS) $$TEXDIR/$(PROJECT).tex 2>&1 | tee $(OUTDIR)/$(PROJECT).tex.log; \

clean:
	rm -rf $(OUTDIR)
